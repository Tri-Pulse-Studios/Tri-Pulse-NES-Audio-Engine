from utils.voice_catalog import VoiceCatalog
from utils.riff_class import UNINIT, NO_DATA, RiffData, SongData
from collections import defaultdict
import re
from typing import List, Dict, Any, Tuple, Optional, Union
from copy import deepcopy
from typing import List, Dict, Any, Optional, Set
from Step_2_Songs.base_pitch import calculate_base_pitches




 

def Format_Pattern_Main_Block(channel_data: SongData, all_notes_data: List[Dict[str, Any]], channel_name: str):
    
    def OLD_lcp_extract_all_repeated_sequences(all_notes_data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:

        def fingerprint_data(all_notes_data: List[Dict[str, Any]]) -> List[int]:
            #TODO: Remove the Volume key from the notes. (For that matter, can do the same to most modifiers)

            """
            Assigns unique integer IDs to 'note' items (ignoring 'pitch_abs'),
            and negative IDs to all non-note items (by type).
            """
            if channel_name == "Noise":
                fingerprint_filter = ("pitch_rel", "ptr") #Noise fingerprints by abs_data.
            else:
                fingerprint_filter = ("pitch_abs", "ptr")

            seen: Dict[Tuple[Tuple[str, Any], ...], int] = {}
            ids: List[int] = []
            next_id = 1
            next_neg_id = -1

            for i, item in enumerate(all_notes_data):

                # Remove pitch_abs and ptr from fingerprinting for ALL items
                item_copy = {k: v for k, v in item.items() if k not in fingerprint_filter}
                item_tuple = tuple(sorted(item_copy.items()))
                
                # Assign IDs based on item type
                if item.get("type") != "note":
                    if item_tuple not in seen:
                        seen[item_tuple] = next_neg_id
                        next_neg_id -= 1
                    ids.append(seen[item_tuple])
                else:
                    if item_tuple not in seen:
                        seen[item_tuple] = next_id
                        next_id += 1
                    ids.append(seen[item_tuple])


            return ids
        
        def extract_repeated_substrings_with_indexes(fingerprinted_data: List[int], all_notes_data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
            def build_suffix_array(fingerprinted_data: List[int]) -> List[int]:
                """
                Constructs the suffix array from a list of integers (IDs).
                Returns a list of start indices sorted by their suffixes.
                """
                return [i for _, i in sorted((fingerprinted_data[i:], i) for i in range(len(fingerprinted_data)))]

            def build_lcp_array(fingerprinted_data: List[int], sa: List[int]) -> List[int]:
                """
                Constructs the Longest Common Prefix (LCP) array for a given fingerprinted_data list and suffix array.
                Each element in LCP indicates how many leading items two adjacent suffixes have in common.
                """
                n = len(fingerprinted_data)
                rank = [0] * n
                for i, si in enumerate(sa):
                    rank[si] = i

                lcp = [0] * (n - 1)
                h = 0
                for i in range(n):
                    if rank[i] == 0:
                        continue
                    j = sa[rank[i] - 1]
                    while i + h < n and j + h < n and fingerprinted_data[i + h] == fingerprinted_data[j + h]:
                        h += 1
                    lcp[rank[i] - 1] = h
                    if h > 0:
                        h -= 1

                return lcp

            def reverse_extend_lcps(fingerprinted_data: List[int], lcp: List[int], sa: List[int], all_notes_data: List[Dict[str, Any]]) -> List[int]:
                """
                Extends LCP values leftward based on custom matching logic:
                - Step 1: Check one step left; if both IDs are positive and their dicts match (except pitch_rel/abs), start extending.
                - Step 2: While fingerprinted_data[a-1] == fingerprinted_data[b-1], keep extending (IDs can be positive or negative).
                """

                new_lcp = [0]*len(lcp)

                if channel_name == "Noise":
                    return new_lcp #Noise doesn't reverse extend

                for i in range(len(lcp)):
                    if lcp[i] == 0:
                        continue  # Skip if no forward match exists
                    a = sa[i]
                    b = sa[i + 1]
                    extended = 0


                    # Step 1: Can we begin extension? (ie: Are Notes of the same length?)
                    Data_secure = any(
                        fingerprinted_data[a + j] > 0
                        for j in range(lcp[i])
                        if (a + j) < len(fingerprinted_data)
                    )

                    while Data_secure:
                        Data_secure = False
                        if a > 0 and b > 0 and fingerprinted_data[a - 1] > 0 and fingerprinted_data[b - 1] > 0:
                            item_a = {k: v for k, v in all_notes_data[a - 1].items() if k not in ("pitch_abs", "pitch_rel", "ptr")}
                            item_b = {k: v for k, v in all_notes_data[b - 1].items() if k not in ("pitch_abs", "pitch_rel", "ptr")}

                            if item_a == item_b:
                                extended += 1
                                a -= 1
                                b -= 1
                                # Step 2: Check for negative fingerprint directly before (ie, Rests, Env_Change, etc)
                                if a > 0 and b > 0 and fingerprinted_data[a - 1] == fingerprinted_data[b - 1] and fingerprinted_data[a - 1] < 0:
                                    extended += 1  # Step 1 + Step 2
                                    a -= 1
                                    b -= 1

                                    # Step 3: Continue matching regardless of sign (Things split apart by this bug.)
                                    while a > 0 and b > 0 and fingerprinted_data[a - 1] == fingerprinted_data[b - 1]:
                                        if fingerprinted_data[a - 1] > 0:
                                            Data_secure = True #If matching notes again, this whole cycle can repeat.
                                        a -= 1
                                        b -= 1
                                        extended += 1

                    new_lcp[i] += extended

                return new_lcp



            def validate_and_append_seq(i, total_len, backward, sa, fingerprinted_data, seen):
                # Get suffix positions
                suffix_a = sa[i]
                suffix_b = sa[i + 1]

                # Compute start positions
                start_a = suffix_a - backward
                start_b = suffix_b - backward


                # Boundary check
                if start_a < 0 or start_b < 0:
                    return

                # Get the candidate sequence from start_a
                seq_len = total_len
                seq = fingerprinted_data[start_a:start_a + seq_len]

                if not any(v >= 1 for v in seq):
                    return #Reject any Riff that has only Rests, Insturment changes, etc

                # Build list of all actual sequences to compare
                candidates = [
                    fingerprinted_data[start:start + seq_len]
                    for start in (start_a, start_b)
                ]
 
                # Find the mismatch index, if any
                mismatch_idx = None
                for idx in range(seq_len):
                    values = {c[idx] for c in candidates}
                    if len(values) > 1:
                        if mismatch_idx is not None:
                            return  # More than one mismatch → invalid
                        mismatch_idx = idx

                # If there is a mismatch, it must be at backward - 1
                if mismatch_idx is not None and mismatch_idx != backward - 1:
                    return  # Mismatch in wrong place → invalid

                elif mismatch_idx is None and backward > 0:
                    norm_pos = backward - 1

                    values_at_pos = {c[norm_pos] for c in candidates}
                    # Only force mismatch if all values are non-negative
                    if all(v >= 0 for v in values_at_pos):
                        mismatch_idx = norm_pos
                    else:
                        print(f"seems like it just means this must match from the start??")
                        return  # Can't normalize negative values → invalid

                elif mismatch_idx is None and backward == 0:
                    if seq[0] > 0:
                        mismatch_idx = None#0

                # Normalize the sequence with 0 at mismatch (if any)
                normalized_seq = list(seq)
                if mismatch_idx is not None:
                    normalized_seq[mismatch_idx] = 0

                seq_tuple = tuple(normalized_seq)

                #Search the entire dataset for additional matches
                extra_candidates = []
                for i in range(len(fingerprinted_data) - seq_len + 1):

                    candidate = tuple(fingerprinted_data[i:i + seq_len])
                    if mismatch_idx is not None:
                        # Normalize for comparison
                        candidate = list(candidate)
                        candidate[mismatch_idx] = 0
                        candidate = tuple(candidate)
                    if candidate == seq_tuple:
                        if mismatch_idx is not None:
                            j = i + mismatch_idx
                            a = start_a + mismatch_idx
                            item_j = {k: v for k, v in all_notes_data[j].items() if k not in ("pitch_abs", "pitch_rel", "ptr")}
                            item_a = {k: v for k, v in all_notes_data[a].items() if k not in ("pitch_abs", "pitch_rel", "ptr")}
                            if item_a == item_j:
                                seen[seq_tuple].add(i)
                            else:
                                print(f"False Possitive Candidate")
                        else:
                            seen[seq_tuple].add(i) 

                return

            def filter_redundant_seq(seen: Dict[Tuple[int, ...], set], results: List[Dict], fingerprinted_data: List[int]) -> List[Dict]:
                # Sort the seen riffs by the first index of each index set
                sorted_seen = sorted(seen.items(), key=lambda item: min(item[1]))

                results = []

                for seq, index_set in sorted_seen:
                    index_list = sorted(index_set)
                    test_len = len(seq)
                    conflict = False

                    i = 0
                    while i < len(index_list) - 1:
                        current_start = index_list[i]
                        next_start = index_list[i + 1]

                        if current_start + test_len > next_start:
                            # Overlap detected: remove the later one
                            index_list.pop(i + 1)
                            continue  # Re-check current index with the new next one
                        i += 1


                    for res in results:
                        accepted_indexes = res['indexes']
                        accepted_len = res['length']

                        # Conflict only if ALL indexes satisfy the formula
                        if len(index_list) != len(accepted_indexes):
                            continue  # Can't match if lengths differ

                        matches_all = True
                        for i in range(len(index_list)):
                            if accepted_len + accepted_indexes[i] != test_len + index_list[i]:
                                matches_all = False
                                break

                        if matches_all:
                            conflict = True
                            break

                    if not conflict and len(index_list) > 1:
                        results.append({
                            'length': test_len,
                            'indexes': index_list,
                            'seq': list(seq),
                        })
                return results
            
            #===Minor-Main===
            sa = build_suffix_array(fingerprinted_data)
            lcp = build_lcp_array(fingerprinted_data, sa)
            extended_lcp = reverse_extend_lcps(fingerprinted_data, lcp, sa, all_notes_data)

            seen: Dict[Tuple[int, ...], set] = defaultdict(set)
            results = []

            for i in range(len(extended_lcp)):
                forward = lcp[i]
                backward = extended_lcp[i]
                total_len = forward + backward



                if total_len >= 3: #Was 2. I got sick of dealing w/ repeated instrument changes. 
                    validate_and_append_seq(i, total_len, backward, sa, fingerprinted_data, seen)

            results = filter_redundant_seq(seen, results, fingerprinted_data)
            return results


        # ---- Main execution flow ----
        fingerprinted_data = fingerprint_data(all_notes_data)
        all_repeated_sequences = extract_repeated_substrings_with_indexes(fingerprinted_data, all_notes_data)
        
        if all_repeated_sequences is not None:
            all_repeated_sequences = score_riffs(all_repeated_sequences, all_notes_data)

        return all_repeated_sequences


    def score_riffs(sequences: List[Dict[str, Any]], all_notes_data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Scores each repeated sequence using fingerprint values.
        Adds 'score' (total savings) and 'indv_score' (per instance savings).
        Skips any riff with indv_score == 0.
        """
        scored_sequences = []

        for seq in sequences:
            indexes = seq['indexes']
            fp_ids = seq['seq']
            base_index = indexes[0]  # use first instance to resolve negative fingerprints

            def get_fp_value(fp, offset):
                if fp >= 0:
                    return 1
                note_index = base_index + offset
                if note_index < 0 or note_index >= len(all_notes_data):
                    raise IndexError(f"Invalid index into all_notes_data: {note_index}")
                note = all_notes_data[note_index]
                note_type = note.get('type')
                if note_type in ('rest', 'Kick SFX', 'repeat'):
                    return 1
                elif note_type == 'Env_Change':
                    return 2
                else:
                    raise ValueError(f"Unimplemented note type: {note_type}")

            length_score = sum(get_fp_value(fp, offset) for offset, fp in enumerate(fp_ids))
            indv_score = length_score - 2
            uses = len(indexes) - 1
            score = indv_score * uses if uses > 0 else 0

            if indv_score > 0:
                new_seq_data = {
                    'score': score,
                    'indv_score': indv_score,
                }
                for key, value in seq.items():
                    if key not in ('score', 'indv_score'):
                        new_seq_data[key] = value
                scored_sequences.append(new_seq_data)
        scored_sequences.sort(key=lambda x: x['indv_score'], reverse=True)
        return scored_sequences



    def build_best_riff(all_repeated_sequences: List[Dict[str, Any]],all_notes_data: List[Dict[str, Any]]) -> List[Dict[int, List[Dict[str, Any]]]]:
        #NOTE: Ranges are start inclusive, end exclusive. (ie, start 10, len 3 is listed as 10 to 13, when it contains 10,11,12)
        
        def list_minor_collisions(best_riff_dict: List[Dict[str, Any]]) -> List[Dict[int, List[Dict[str, Any]]]]:
            """
            Build a collision map: for each riff, store which other riffs it collides with and where.
            Adds a 'collide_at_start' flag to indicate whether the overlap cuts into the start of the riff.
            """

            def get_ranges(riff):
                # Helper function to return start-end ranges for a riff's indexes
                return [(start, start + riff['length']) for start in riff['indexes']]

            num_riffs = len(best_riff_dict)
            all_collisions = [{} for _ in range(num_riffs)]  # initialize empty dictionaries for each riff

            for i, riff_a in enumerate(best_riff_dict):
                if riff_a is None: # or riff_a.get('indv_score') <= 4:
                    continue


                ranges_a = get_ranges(riff_a)
                for j, riff_b in enumerate(best_riff_dict):
                    if riff_b is None: #or riff_b.get('indv_score') <= 4:
                        continue

                    if i >= j:  # Only compare distinct pairs
                        continue


                    ranges_b = get_ranges(riff_b)


                    for start_a, end_a in ranges_a:
                        for start_b, end_b in ranges_b:
                            if start_a <= start_b and end_a >= end_b:
                                continue  # B fully inside A — not considered a collision
                            if start_a >= start_b and end_a <= end_b:
                                continue  # A fully inside B — not a collision
                            if start_a < end_b and end_a > start_b:
                                # Collision detected, add the information
                                all_collisions[i].setdefault(j, []).append({
                                    "collision_at": start_a,
                                    "collidee_started_at": start_b,
                                    "collide_at_start": start_a > start_b
                                })
                                all_collisions[j].setdefault(i, []).append({
                                    "collision_at": start_b,
                                    "collidee_started_at": start_a,
                                    "collide_at_start": start_b > start_a
                                })

            # Organize the minor collisions by root_id
            minor_collisions = []

            for root_id, collisions in enumerate(all_collisions):
                if collisions:
                    collisions_by_index = {}
                    for collidee_id, entries in collisions.items():
                        for entry in entries:
                            idx = entry['collision_at']
                            detailed = {
                                "collidee_id": collidee_id,
                                "collidee_started_at": entry['collidee_started_at'],
                                "collide_at_start": entry['collide_at_start']
                            }
                            collisions_by_index.setdefault(idx, []).append(detailed)
                    minor_collisions.append({
                        "root_id": root_id,
                        "collisions_by_index": collisions_by_index
                    })
                else:
                    minor_collisions.append(None)

            return minor_collisions



        def list_major_collisions(minor_collisions: List[Optional[Dict[int, List[Dict[str, Any]]]]]) -> List[Optional[Dict[str, Any]]]:
            """
            Identify major collisions and return structured fingerprinted_data:
            - root_id: the riff this set of collisions centers on
            - collisions_by_index: maps 'collision_at' values to lists of full collision records
            Each collision record includes:
            - collidee_id
            - collidee_started_at
            - collide_at_start: True if the collidee ends inside the root
            """

            # Deepcopy the minor collisions
            major_collisions = deepcopy(minor_collisions)

            for root_id, riff_collisions in enumerate(major_collisions):
                if riff_collisions is None:
                    continue

                collisions_by_index = riff_collisions.get('collisions_by_index', {})

                # If there is only one site of collisions, this isn't Major.
                if len(collisions_by_index) <= 1:
                    major_collisions[root_id] = None

            return major_collisions

        def list_tangled_collisions(major_collisions: List[Optional[Dict[str, Any]]]) -> List[Dict[str, Any]]:
            """
            Build a separate list of tangles, parallel to major_collisions.
            Each index contains a list of tangled collision records for that riff, or None.
            Tracks the two root IDs involved in the collision, and where both started.
            """

            # Create root_ids_map: Collect all collidee_ids for each root_id (involved in collisions)
            root_ids_map = {
                i: [] for i, entry in enumerate(major_collisions) if entry is not None
            }

            for root_id, entry in enumerate(major_collisions):
                if entry is None:
                    continue
                for idx, entries in entry.get("collisions_by_index", {}).items():
                    for e in entries:
                        if e["collidee_id"] not in root_ids_map[root_id]:
                            root_ids_map[root_id].append(e["collidee_id"])

            # Prune root_ids_map by keeping only entries that are themselves root ids
            pruned_root_ids_map = {}
            for root_id, collidees in root_ids_map.items():
                pruned_collidees = []
                for collidee_id in collidees:
                    if collidee_id < root_id and collidee_id in root_ids_map:
                        pruned_collidees.append(collidee_id)
                if pruned_collidees:
                    pruned_root_ids_map[root_id] = pruned_collidees

            # Start building tangled_collisions by selectively copying from major_collisions
            tangled_collisions = []

            for root_id, entry in enumerate(major_collisions):
                if entry is None:
                    continue

                tangled = {
                    "root_id": root_id,
                    "collisions_by_index": {}
                }

                for idx, entries in entry.get("collisions_by_index", {}).items():
                    filtered_entries = []
                    for e in entries:
                        if e["collidee_id"] in pruned_root_ids_map.get(root_id, []):
                            filtered_entries.append(e)

                    if filtered_entries:
                        tangled["collisions_by_index"][idx] = filtered_entries

                if tangled["collisions_by_index"]:
                    tangled_collisions.append(tangled)

            return tangled_collisions


        def resolve_collision_group(root_id: int,collision_index: int,collidee_data: List[Dict[str, Any]],best_riff_dict: List[Optional[Dict[str, Any]]]) -> List[Optional[Dict[str, Any]]]:
            colliding_at_start = []
            colliding_at_end = []

            for entry in collidee_data:
                riff_id = entry['collidee_id']
                if 0 <= riff_id < len(best_riff_dict) and best_riff_dict[riff_id] is not None:
                    if entry['collide_at_start']:
                        colliding_at_start.append(entry)
                    else:
                        colliding_at_end.append(entry)

        
            colliding_at_end.sort(key=lambda x: x['collidee_started_at'])

            # id_to_length = {i: riff['length'] for i, riff in enumerate(best_riff_dict)}

            # colliding_at_end.sort(
            #     key=lambda x: (x['collidee_started_at'], -id_to_length[x['collidee_id']])
            # )


            for collidee in colliding_at_end:
                root_riff = best_riff_dict[root_id]
                if root_riff is None:
                    break
                collidee_id = collidee['collidee_id']
                collidee_riff = best_riff_dict[collidee_id]
                if collidee_riff is None:
                    continue

                root_indv_score = root_riff['indv_score']
                other_indv_score = collidee_riff['indv_score']

                root_start = collision_index
                root_end = root_start + root_riff['length']
                other_start = collidee['collidee_started_at']

                overlap = root_end - other_start

                if overlap + 2 >= root_indv_score or overlap + 2 >= other_indv_score:
                    if root_indv_score <= other_indv_score:
                        idx_len = len(root_riff['indexes'] or 0)
                        if idx_len <= 2:
                            best_riff_dict[root_id] = None
                        else: 
                            root_riff['indexes'].remove(root_start)
                            best_riff_dict[root_id] = root_riff
                        return best_riff_dict
                    else:
                        if len(collidee_riff['indexes']) <= 2:
                            best_riff_dict[collidee_id] = None
                        else:
                            collidee_riff['indexes'].remove(other_start)
                        continue
                else:
                    if 'shortened_indexes' not in root_riff:
                        root_riff['shortened_indexes'] = []

                    existing_entry = next((entry for entry in root_riff['shortened_indexes'] if entry['old_start'] == root_start), None)

                    if existing_entry:
                        if root_end - overlap < existing_entry['new_end']:
                            existing_entry['new_end'] = root_start + overlap
                            new_length = existing_entry['new_end'] - existing_entry['new_start']
                            if new_length >= 3:
                                existing_entry['new_length'] = new_length
                            else:
                                if len(root_riff['indexes']) <= 2:
                                    best_riff_dict[root_id] = None
                                else: 
                                    root_riff['indexes'].remove(root_start)
                                    best_riff_dict[root_id] = root_riff
                                return best_riff_dict
                    else:
                        if root_end -overlap - root_start >= 3:
                            root_riff['shortened_indexes'].append({
                                'old_start': root_start,
                                'new_start': root_start,
                                "new_end": root_end - overlap,
                                'new_length': root_end -overlap - root_start
                            })
                        else:
                            if len(root_riff['indexes']) <= 2:
                                best_riff_dict[root_id] = None
                            else: 
                                root_riff['indexes'].remove(root_start)
                                best_riff_dict[root_id] = root_riff
                            return best_riff_dict
                        
                    best_riff_dict[root_id] = root_riff
                    break





            colliding_at_start.sort(
                key=lambda x: (
                    x['collidee_started_at'] + best_riff_dict[x['collidee_id']]['length']
                    if best_riff_dict[x['collidee_id']] else 0,
                    best_riff_dict[x['collidee_id']]['length']
                    if best_riff_dict[x['collidee_id']] else 0
                ),
                reverse=True
            )

            for collidee in colliding_at_start:
                root_riff = best_riff_dict[root_id]
                if root_riff is None:
                    break
                collidee_id = collidee['collidee_id']
                collidee_riff = best_riff_dict[collidee_id]
                if collidee_riff is None:
                    continue

                root_indv_score = root_riff['indv_score']
                other_indv_score = collidee_riff['indv_score']

                root_start = collision_index
                root_end = root_start + root_riff['length']
                other_start = collidee['collidee_started_at']
                other_end = other_start + collidee_riff['length']

                overlap = other_end - root_start

                if overlap + 2 >= root_indv_score or overlap + 2 >= other_indv_score:
                    if root_indv_score <= other_indv_score:
                        if len(root_riff['indexes']) <= 2:
                            best_riff_dict[root_id] = None
                        else: 
                            root_riff['indexes'].remove(root_start)
                        return best_riff_dict
                    else:
                        if len(collidee_riff['indexes']) <= 2:
                            best_riff_dict[collidee_id] = None
                        else:
                            collidee_riff['indexes'].remove(other_start)
                        continue
                else:
                    if 'shortened_indexes' not in root_riff:
                        root_riff['shortened_indexes'] = []

                    existing_entry = next((entry for entry in root_riff['shortened_indexes'] if entry['old_start'] == root_start), None)

                    if existing_entry:
                        if root_start + overlap > existing_entry['new_start']:
                            existing_entry['new_start'] = root_start + overlap
                            new_length = existing_entry['new_end'] - existing_entry['new_start']
                            if new_length >= 3:
                                existing_entry['new_length'] = new_length
                            else:
                                if len(root_riff['indexes']) <= 2:
                                    best_riff_dict[root_id] = None
                                else: 
                                    root_riff['indexes'].remove(root_start)
                                    best_riff_dict[root_id] = root_riff
                                return best_riff_dict
                    else:
                        if root_end - root_start - overlap >= 3:
                            root_riff['shortened_indexes'].append({
                                'old_start': root_start,
                                'new_start': root_start + overlap,
                                "new_end": root_end,
                                'new_length': root_end - root_start - overlap
                            })

                        else:
                            if len(root_riff['indexes']) <= 2:
                                best_riff_dict[root_id] = None
                            else: 
                                root_riff['indexes'].remove(root_start)
                                best_riff_dict[root_id] = root_riff
                            return best_riff_dict


                    best_riff_dict[root_id] = root_riff
                    break

            return best_riff_dict



        def resolve_tangled_collisions(
            tangled_collisions: List[Dict[str, Any]],
            best_riff_dict: Dict[int, Dict[str, Any]]
        ) -> List[Dict[str, Any]]:

            for tangle in tangled_collisions:
                root_id = tangle['root_id']
                collisions_by_index = tangle['collisions_by_index']

                for collision_index, collidee_data in collisions_by_index.items():


                    best_riff_dict = resolve_collision_group(root_id, collision_index, collidee_data, best_riff_dict)


            return best_riff_dict


        def resolve_major_collisions(
            major_collisions: List[Optional[Dict[str, Any]]],
            best_riff_dict: Dict[int, Optional[Dict[str, Any]]]
        ) -> Dict[int, Optional[Dict[str, Any]]]:
            for major in major_collisions:
                if major is None:
                    continue

                root_id = major['root_id']
                collisions_by_index = major['collisions_by_index']

                if best_riff_dict[root_id] is None:
                    continue  # Skip if root was removed

                root_riff = best_riff_dict[root_id]
                root_length = root_riff['length']

                # Step 1: Score all indexes
                index_scores = {}
                for collision_index, collidee_data in collisions_by_index.items():
                    root_start = collision_index
                    root_end = root_start + root_length
                    score = 0

                    for entry in collidee_data:
                        collidee_id = entry['collidee_id']
                        if best_riff_dict[collidee_id] is None:
                            continue

                        other_start = entry['collidee_started_at']
                        other_end = other_start + best_riff_dict[collidee_id]['length']

                        overlap = min(root_end, other_end) - max(root_start, other_start)
                        if overlap > 0:
                            score += overlap

                    index_scores[collision_index] = score



                # Step 2: Find the best index to preserve (max score)
                best_index = max(index_scores.items(), key=lambda x: x[1])[0]

                # Step 3: Resolve all *other* indexes
                for collision_index, collidee_data in collisions_by_index.items():
                    if collision_index == best_index:
                        continue  # Skip this one, it's preserved

                    best_riff_dict = resolve_collision_group(
                        root_id,
                        collision_index,
                        collidee_data,
                        best_riff_dict
                    )

            return best_riff_dict


        def clean_best_riff_dict(best_riff_dict):

            def add_cleaned_riff(riff, group_data, cleaned_best_riff_dict):
                combined_indexes = group_data['indexes']
                new_length = group_data['new_len']
                old_length = riff['length']
                shift = group_data['shift']
                
                if len(combined_indexes) < 2 and old_length != new_length:
                    print(f"Unimplemented complexity resolving riff: {riff}. The whole set needs to trim so the new ends and new starts have common ground.")
                    #In short, it needs to find the idx whose overlap includes as much of the lone one as possible.
                    return cleaned_best_riff_dict

                if len(combined_indexes) < 2 and old_length == new_length:
                    #The "Original" just collapses into the modified.
                    return cleaned_best_riff_dict

                cleaned_riff = {}
                adjusted_indexes = [idx + shift for idx in combined_indexes]

                cleaned_riff['length'] = new_length
                cleaned_riff['indexes'] = adjusted_indexes 
                cleaned_riff['seq'] = riff['seq'][shift:shift + new_length]
                cleaned_best_riff_dict.append(cleaned_riff)
                
                return cleaned_best_riff_dict

            def create_groups(riff, shortened):
                groups = []
                old_length = riff.get('length')
                index_list = riff.get('indexes')
                seen_keys = set()

                for base_short in shortened:
                    new_length = base_short['new_length'] #FIRST THOUGHT TO FIX NOISE BAD RIFFS: See if new length is 2 or less.
                    
                    if new_length <= 2:
                        print(f"Delete this short riff.")

                    shift = old_length - new_length
                    key = (shift, new_length)  # Use a tuple instead of a dictionary for the key

                    # Avoid redundant group building
                    if key in seen_keys:
                        continue
                    seen_keys.add(key)

                    # Initialize the group dictionary with 'new_len', 'shift', and an empty 'indexes' list
                    groups.append({'new_len': new_length, 'shift': shift, 'indexes': []})
                    group_id = len(groups)-1

                    for idx in index_list:
                        for short in shortened:
                            is_short = False
                            if short['old_start'] == idx:
                                is_short = True
                                break
                        if is_short:
                            candidate_new_length = short['new_length']
                            candidate_shift = old_length - candidate_new_length
                            if candidate_shift == shift and candidate_new_length >= new_length:
                                groups[group_id]['indexes'].append(idx)
                        else:
                            groups[group_id]['indexes'].append(idx)

                # --- Add "originals" group ---
                all_shorted_indexes = {short['old_start'] for short in shortened}
                original_indexes = [idx for idx in index_list if idx not in all_shorted_indexes]
                if original_indexes:
                    groups.append({
                        'new_len': old_length,
                        'shift': 0,
                        'indexes': original_indexes
                    })
                return groups


            def filter_redundant_cleaned_riffs(cleaned_best_riff_dict: List[Dict]) -> List[Dict]:
                # Sort the cleaned riffs based on their first index
                cleaned_best_riff_dict = [
                    entry for entry in cleaned_best_riff_dict
                    if entry.get("indexes") and len(entry["indexes"]) > 1
                ] #Delete empty ones.

                cleaned_best_riff_dict_sorted = sorted(cleaned_best_riff_dict, key=lambda x: min(x['indexes']))

                results = []

                for riff in cleaned_best_riff_dict_sorted:
                    # Extract sequence and indexes
                    seq = riff['seq']
                    index_list = sorted(riff['indexes'])
                    test_len = len(seq)
                    conflict = False

                    # Check for overlap between indexes (probably unneeded.)
                    i = 0
                    while i < len(index_list) - 1:
                        current_start = index_list[i]
                        next_start = index_list[i + 1]

                        if current_start + test_len > next_start:
                            # Overlap detected: remove the later one
                            index_list.pop(i + 1)
                            continue  # Re-check current index with the new next one
                        i += 1

                    # Check against existing results for conflicts based on sequence and indexes
                    for res in results:
                        accepted_indexes = res['indexes']
                        accepted_len = res['length']

                        # Conflict only if ALL indexes satisfy the formula
                        if len(index_list) != len(accepted_indexes):
                            continue  # Can't match if lengths differ

                        matches_all = True
                        for i in range(len(index_list)):  #NOTE, the other filter function is looser than this, mostly by sheer laziness.
                            riff_start = index_list[i]
                            riff_end = riff_start + test_len

                            accept_start = accepted_indexes[i]
                            accept_end = accept_start + accepted_len

                            if not (riff_start >= accept_start and riff_end <= accept_end):
                                matches_all = False
                                break

                        if matches_all:
                            conflict = True
                            break

                    # If there's no conflict and the length is greater than 1, add it to results
                    if not conflict and len(index_list) > 1:
                        results.append({
                            'score': riff.get('score', "Unknown"),
                            'indv_score': riff.get('indv_score', "Unknown"),
                            'length': test_len,
                            'indexes': index_list,
                            'seq': list(seq),
                        })

                return results


            def filter_colliding_sub_riffs(best_riff_dict: List[Dict]) -> Dict[int, List[Dict]]:
                def find_same_length_collision_pairs(minor_collisions, best_riff_dict):
                    pairs_to_analyze = set()

                    for entry in minor_collisions:
                        if entry is None:
                            continue

                        root_id = entry['root_id']
                        root_indexes = best_riff_dict[root_id].get('indexes', [])
                        root_len = len(root_indexes)

                        for collision_list in entry['collisions_by_index'].values():
                            for collision in collision_list:
                                collidee_id = collision['collidee_id']
                                collidee_indexes = best_riff_dict[collidee_id].get('indexes', [])
                                collidee_len = len(collidee_indexes)

                                if root_len == collidee_len:
                                    pair = frozenset({root_id, collidee_id})
                                    pairs_to_analyze.add(pair)

                    return list(pairs_to_analyze)
                

                def list_colliding_sub_riffs(pair: frozenset) -> Set[int]:
                    def all_overlap(indexes_1, len_1, indexes_2, len_2):
                        for i1 in indexes_1:
                            start1 = i1
                            end1 = i1 + len_1
                            found_overlap = False
                            for i2 in indexes_2:
                                start2 = i2
                                end2 = i2 + len_2
                                if start1 < end2 and end1 > start2:
                                    found_overlap = True
                                    break
                            if not found_overlap:
                                return False
                        return True

                    id_a, id_b = tuple(pair)
                    riff_a = best_riff_dict[id_a]
                    riff_b = best_riff_dict[id_b]

                    len_a = riff_a['length']
                    len_b = riff_b['length']
                    indexes_a = riff_a['indexes']
                    indexes_b = riff_b['indexes']

                    a_fully_overlapped_by_b = all_overlap(indexes_a, len_a, indexes_b, len_b)
                    b_fully_overlapped_by_a = all_overlap(indexes_b, len_b, indexes_a, len_a)

                    if a_fully_overlapped_by_b and b_fully_overlapped_by_a:
                        # Both fully overlap each other — delete the shorter one
                        if len_a < len_b:
                            return {id_a}
                        else:
                            return {id_b}
                    else:
                        return set()

                #=== Minor Main===
                minor_collisions = list_minor_collisions(best_riff_dict)
                pairs_to_analyze = find_same_length_collision_pairs(minor_collisions, best_riff_dict)


                to_delete_ids = set()
                for pair in pairs_to_analyze:
                    delete = list_colliding_sub_riffs(pair)
                    to_delete_ids.update(delete)

                best_riff_dict = [riff for i, riff in enumerate(best_riff_dict) if i not in to_delete_ids]
                
                return best_riff_dict

            #=== Minor Main ===
            cleaned_best_riff_dict = []

            for riff in best_riff_dict:
                if riff is None:
                    continue

                shortened = riff.get('shortened_indexes', None)
                if shortened is None:
                    cleaned_best_riff_dict.append(riff)
                    continue

                
                elif shortened:
                    groups = create_groups(riff, shortened)
                    for group_data in groups:
                        cleaned_best_riff_dict = add_cleaned_riff(riff, group_data, cleaned_best_riff_dict)
                else:
                    print(f"Riff got marked as [] for its shortened indexes: {riff}")
                    continue
                 

            best_riff_dict = filter_redundant_cleaned_riffs(cleaned_best_riff_dict)
            best_riff_dict = filter_colliding_sub_riffs(best_riff_dict)
            return best_riff_dict





        #=== Major Main===
        best_riff_dict = deepcopy(all_repeated_sequences)

        minor_collisions = list_minor_collisions(best_riff_dict)
        major_collisions = list_major_collisions(minor_collisions)
        tangled_collisions = list_tangled_collisions(major_collisions)
      
        best_riff_dict = resolve_tangled_collisions(tangled_collisions, best_riff_dict)

        best_riff_dict = clean_best_riff_dict(best_riff_dict)
        best_riff_dict = score_riffs(best_riff_dict, all_notes_data)

        minor_collisions = list_minor_collisions(best_riff_dict)
        major_collisions = list_major_collisions(minor_collisions)  
        tangled_collisions = list_tangled_collisions(major_collisions)
        if tangled_collisions:
            best_riff_dict = force_delete_tangled_ids(tangled_collisions, best_riff_dict)
            print(f"Still Tangles. Forced Deleted")

            minor_collisions = list_minor_collisions(best_riff_dict)
            major_collisions = list_major_collisions(minor_collisions)  
            tangled_collisions = list_tangled_collisions(major_collisions)
            #raise ValueError (f"Not all tangles removed.") 

        best_riff_dict = resolve_major_collisions(major_collisions, best_riff_dict)

        best_riff_dict = clean_best_riff_dict(best_riff_dict)
        best_riff_dict = score_riffs(best_riff_dict, all_notes_data)

        minor_collisions = list_minor_collisions(best_riff_dict)
        major_collisions = list_major_collisions(minor_collisions)
        tangled_collisions = list_tangled_collisions(major_collisions)
        if any(major is not None for major in major_collisions):
            raise ValueError (f"Not all majors resolved.") 
        
        return best_riff_dict, minor_collisions


    def force_delete_tangled_ids(tangled_collisions, best_riff_dict):
        for collision in tangled_collisions:
            root_id = collision['root_id']
            indexes_to_remove = collision['collisions_by_index'].keys()

            # Filter the indexes in best_riff_dict[root_id] to exclude those in indexes_to_remove
            original_indexes = best_riff_dict[root_id]['indexes']
            best_riff_dict[root_id]['indexes'] = [idx for idx in original_indexes if idx not in indexes_to_remove]
        return best_riff_dict







    #The help of letter riffs will be to fist knock out the biggest sections first. Basically, the can give me a start/end idx I can do an initial pruning on
        
    #Improvement Ideas:
    """
    The common item keep-er together. 
        If all X have Y after, bundle X w/ those Ys (ie, A = xy for all y's w/ an x before em.) before the main brute forcer. (
            -Would be part of the same system, and have to log the idxes marked as deeply nested. (Though I may as well just make those call objects then and fingerprint off those.)
    """

    #To Fix:
    """
    Non-Tri needs that flag that, the first note it reads, it can use all notes of the same length to start
    """

    def brute_force_forward_riffs(all_notes_data: List[Dict[str, Any]]):
        def generate_fingerprints() -> List[Tuple]:

            def dispatch_entry(entry:Dict[str, Any]):
                def fingerprint_init_header(entry):
                    return ("Init_Header",)

                def fingerprint_string(entry):
                    print(f"I want to depreciate strings in all notes data.")
                    return (entry["string"],)

                def fingerprint_note(entry):
                    if channel_name == "Noise":
                        fingerprint = ("note", entry["length"], entry["pitch_abs"])  # Noise fingerprints by abs_data.
                    else:
                        fingerprint = ("note", entry["length"], entry["pitch_rel"])
                    return fingerprint

                def fingerprint_rest(entry):
                    return ("rest", entry["length"])

                def fingerprint_Env_Change(entry):
                    return ("Env_Change", entry["new_env_pointer"])

                def fingerprint_repeat(entry):
                    return ("repeat", entry["id"], entry["count"])

                def fingerprint_kick_sfx(entry):
                    return ("kick_sfx",)

                entry_type = entry.get("type")
                type_handlers = {
                    "string": fingerprint_string,
                    "Init_Header": fingerprint_init_header,
                    "note": fingerprint_note,
                    "rest": fingerprint_rest,
                    "Env_Change": fingerprint_Env_Change,
                    "repeat": fingerprint_repeat,
                    "Kick SFX": fingerprint_kick_sfx,
                }

                handler = type_handlers.get(entry_type)
                if handler:
                    return handler(entry)
                else:
                    raise ValueError(f"Unimplemented note_data_type: {entry_type}")

            fingerprinted_list = []
            for entry in all_notes_data:
                fp = dispatch_entry(entry)
                fingerprinted_list.append(fp)

            return fingerprinted_list
        
        def build_idx_to_indexes_map(fingerprinted_list: List[Tuple]) -> Tuple[List[Set[int]], Dict[Tuple, Set[int]]]:
            fingerprint_to_indexes = defaultdict(set)  # sets, not lists

            # Group all indexes by their fingerprint
            for idx, fp in enumerate(fingerprinted_list):
                fingerprint_to_indexes[fp].add(idx)  # add to set

            # Initialize list of sets
            idx_to_indexes_map = [set() for _ in range(len(fingerprinted_list))]

            for fp, indexes in fingerprint_to_indexes.items():
                for idx in indexes:
                    # Set of other indexes sharing the fingerprint (exclude self)
                    idx_to_indexes_map[idx] = indexes - {idx}

            fp_groups = dict(fingerprint_to_indexes)
            return idx_to_indexes_map, fp_groups


        def build_note_length_index_map(fingerprinted_list: List[Tuple]) -> Tuple[List[Set[int]], Dict[int, Set[int]]]:
            from collections import defaultdict

            length_to_indexes_map = defaultdict(set)

            # Group indexes of notes by their length
            for idx, fp in enumerate(fingerprinted_list):
                if fp[0] == "note":
                    note_length = fp[1]  # ("note", length, pitch)
                    length_to_indexes_map[note_length].add(idx)

            idx_to_length_group = [set() for _ in range(len(fingerprinted_list))]

            # Fill in per-index reverse map (same length notes, excluding self)
            for length, indexes in length_to_indexes_map.items():
                for idx in indexes:
                    idx_to_length_group[idx] = indexes - {idx}

            return length_to_indexes_map


        #Same as the Class below. The Class is much less messy.
        def brute_forcer(fingerprinted_list: List[Tuple], idx_to_indexes_map: List[Set[int]], ):
            def detect_self_ref(valid_paths: Set[int], i: int) -> Set[int]:
                """Filter out any riffs whose source range [x - length, x) overlaps with [idx, i)."""
                length = i - idx
                result = set()

                for x in valid_paths:
                    start = x - length
                    end = x

                    # Check for overlap with [idx, i)
                    if end > idx and start < i:
                        # This one overlaps, skip it
                        continue

                    result.add(x)

                return result

            def deepen_riff_layer(start: int, end: int, source_depth: int):
                target_depth = source_depth + 1
                if not (0 <= target_depth <= max_allowed_riff_depth):
                    raise ValueError(f"Invalid target depth: {target_depth}, for max depth: {max_allowed_riff_depth}")

                for idx in range(start, end):
                    current_layer_idx = None
                    # Find current layer of idx
                    for layer_idx, layer_set in enumerate(riff_depth_layers):
                        if idx in layer_set:
                            current_layer_idx = layer_idx
                            break
                    
                    if current_layer_idx is None:

                        raise ValueError(f"Index {idx} not found in any riff depth layer.")
                    
                    # Determine final layer to put idx in (deeper of current or target)
                    final_layer_idx = max(current_layer_idx, target_depth)
                    
                    if current_layer_idx > target_depth:
                        print(f"Note: Index {idx} already deeper (layer {current_layer_idx}) than target {target_depth}")

                    # If index not in final layer, move it
                    if idx not in riff_depth_layers[final_layer_idx]:
                        # Remove from current layer
                        riff_depth_layers[current_layer_idx].remove(idx)
                        # Add to final layer
                        riff_depth_layers[final_layer_idx].add(idx)


            def pop_called_idxes(start: int, end: int):
                riff_call_depth = None

                for idx in range(start, end):
                    found_layers = [i for i, layer in enumerate(riff_depth_layers) if idx in layer]
                    if len(found_layers) != 1:
                        raise ValueError(f"Index {idx} is in {len(found_layers)} layers: {found_layers}")
                    
                    if riff_call_depth is None:
                        riff_call_depth = found_layers[0]
                    elif riff_call_depth != found_layers[0]:
                        raise ValueError(f"Index {idx} in inconsistent layer {found_layers[0]} (expected {riff_call_depth})")

                for idx in range(start, end):
                    riff_depth_layers[riff_call_depth].remove(idx)

                return riff_call_depth


            def find_calls_to_this_idx(idx: int, valid_paths: Set[int]) -> Tuple[int, int]:
                def incriment_valid_paths(valid_paths: Set[int]) -> Set[int]:
                    return {x + 1 for x in valid_paths}



                debug = fingerprinted_list


                i = idx
                valid_paths -= called_idxes
                if valid_paths != valid_paths - riff_depth_layers[-1] and min_required_len > 3:
                    print (f"[WARN] Hitting maximum Riff Depth. Processing riff size: {min_required_len}")
                valid_paths -= riff_depth_layers[-1] #Don't start a new call if this point is at max-riff-depth
                while i < len(idx_to_indexes_map):

                    i += 1
                    valid_paths = incriment_valid_paths(valid_paths)
                    
                    non_self_referencing = detect_self_ref(valid_paths.copy(), i)
                    if not valid_paths & non_self_referencing: #Must be checked and removed before the other checks. Not sure why.
                        print (f"Do I need to i -= 1 to prevent Self-Referencing?")
                        break 
                    valid_paths &= non_self_referencing
                    

                    if i in called_idxes: #If hitting a call, we're done.
                        break
                    

                    next_valid_paths = valid_paths.copy()

                    next_valid_paths -= called_idxes# Already Called.
                    next_valid_paths -= labeled_idxes # Can't Delete Labels

                    next_set = idx_to_indexes_map[i] #Try extending seqence.
                    next_valid_paths &= next_set


                    if next_valid_paths:
                        valid_paths = next_valid_paths
                        continue
                    else:
                        break

                return i, valid_paths 
                        

            def walk_all_indexes(min_required_len):
                def handle_new_riff():

                           
                           #callable_idxes = set()       not all "new" idxes already available.
                        callable_idxes.update(range(idx, i))
                        labeled_idxes.update({idx, i})
                        
                        
                        new_riff = channel_data.create_new_riff(start=idx, end=i)

                        new_called_idxes = set()
                        deepest_riff_depth = float("-inf") #I can be smart about the max riff depth and assign the og_data to the point w/ the highest riff depth (since only calls deepen it)
                        for call_end in valid_paths:
                            
                            call_start = call_end - length
                            call_range = set(range(call_start, call_end))
                            
                            if call_range & new_called_idxes:
                                print(f"Two calls to the same riff tried to use the same data. How common?")
                                continue 

                            new_riff.add_index(call_start)
                            new_called_idxes.update(call_range)
                            riff_call_depth = pop_called_idxes(call_start, call_end)
                            if deepest_riff_depth < riff_call_depth:
                                deepest_riff_depth = riff_call_depth
                            
                        deepen_riff_layer(idx, i, deepest_riff_depth)

                        called_idxes.update(new_called_idxes)






                debug = all_notes_data
                debug = riff_depth_layers
                nonlocal idx
                max_unprocessed_len = 0 
                while idx < len(fingerprinted_list):
                    this_idxes_set = idx_to_indexes_map[idx]
                    

                    if not this_idxes_set or idx in called_idxes:
                        idx += 1 #Skip singletons and processed entries.
                        continue
                        
                    
                    valid_paths = this_idxes_set.copy()

                    i, valid_paths = find_calls_to_this_idx(idx, valid_paths)
                    length = i - idx



                    if length >= min_required_len:

                        handle_new_riff()

                        idx = i
                        continue


                    else:
                        if max_unprocessed_len < length: #Is it the longest found thus far?
                            max_unprocessed_len = length
                        idx += 1
                        continue
                return max_unprocessed_len



                #return end_idx, main_riff

            #=== Sub Main ===

            debug = all_notes_data
            callable_idxes = set() #indexes marked available to be called #VESTIGIAL
            called_idxes = set() #indexes that don't exist cuz called                   
            labeled_idxes = set()#indexes that must exist

            max_allowed_riff_depth = 3 #RAM addresses per channel. 0 is considered Root
            riff_depth_layers = [set() for _ in range(max_allowed_riff_depth + 1)]
            riff_depth_layers[0] = set(range(len(all_notes_data)))

            min_required_len = float("inf") #first time, just find the max length.
            while min_required_len >= 3: #idx < len(fingerprinted_list):
                idx = 0 #scan whole list each time.

                max_unprocessed_len = walk_all_indexes(min_required_len)
                if max_unprocessed_len >= min_required_len:
                    raise ValueError (f"Malfunction getting riffs. Something wasn't processed when it should've been.")

                min_required_len = max_unprocessed_len #Process just the length of the longest remaining first.
            
            all_indexes = set(range(len(all_notes_data)))
            debug_unused_indexes = all_indexes - callable_idxes - called_idxes
            double_used = callable_idxes & called_idxes


            for depth in reversed(range(len(riff_depth_layers))):
                if riff_depth_layers[depth]:
                    reached_riff_depth = depth #This should go in the Class object.

            return



        class RiffBruteForcer:
            def __init__(
                self,
                fingerprinted_list: List[Tuple],
                idx_to_indexes_map: List[Set[int]],
                length_to_indexes_map: Dict[int, Set[int]],
                all_notes_data: List[Dict[str, Any]]
                ):                
                self.fingerprinted_list = fingerprinted_list
                self.idx_to_indexes_map = idx_to_indexes_map
                self.all_notes_data = all_notes_data
                self.length_to_indexes_map = length_to_indexes_map

                self.callable_idxes = set()
                self.called_idxes = set()
                self.labeled_idxes = set()

                self.max_allowed_riff_depth = 3
                if channel_name == "Noise":
                    self.minimum_riff_size = 3
                else:
                    self.minimum_riff_size = 4 
                    """
                    i can do Min 3, but have to do something to prevent dumb shifts to tiny Riffs.
                    """

                self.riff_depth_layers = [set() for _ in range(self.max_allowed_riff_depth + 1)]
                self.riff_depth_layers[0] = set(range(len(self.all_notes_data)))

            def detect_self_ref(self, valid_paths: Set[int], idx: int, og_end_idx: int) -> Set[int]:
                length = og_end_idx - idx
                return {
                    x for x in valid_paths
                    if not (x + 1 > idx and (x - length) < og_end_idx + 1) #Plus ones new.
                }

            def deepen_riff_layer(self, start: int, end: int, source_depth: int):
                target_depth = source_depth + 1
                if not (0 <= target_depth <= self.max_allowed_riff_depth):
                    raise ValueError(f"Invalid target depth: {target_depth}, for max depth: {self.max_allowed_riff_depth}")

                for idx in range(start, end):
                    current_layer_idx = None
                    for layer_idx, layer_set in enumerate(self.riff_depth_layers):
                        if idx in layer_set:
                            current_layer_idx = layer_idx
                            break

                    if current_layer_idx is None:
                        return
                        raise ValueError(f"Index {idx} not found in any riff depth layer.")

                    final_layer_idx = max(current_layer_idx, target_depth)
                    if idx not in self.riff_depth_layers[final_layer_idx]:
                        self.riff_depth_layers[current_layer_idx].remove(idx)
                        self.riff_depth_layers[final_layer_idx].add(idx)

            def pop_called_idxes(self, start: int, end: int) -> int:
                riff_call_depth = None
                for idx in range(start, end):
                    found_layers = [i for i, layer in enumerate(self.riff_depth_layers) if idx in layer]
                    if len(found_layers) != 1:
                        raise ValueError(f"Index {idx} is in {len(found_layers)} layers: {found_layers}")

                    if riff_call_depth is None:
                        riff_call_depth = found_layers[0]
                    elif riff_call_depth != found_layers[0]:
                        raise ValueError(f"Inconsistent riff depth for index {idx}")

                for idx in range(start, end):
                    self.riff_depth_layers[riff_call_depth].remove(idx)

                return riff_call_depth

            #Suspected ipmrovements to be made:
            #Before marking something as called vs callable, check wether the new callable is callable, and if not, whether any of the called is callable. 
            #   -Can probably do this w/ the deepest riff tracking idea.

            def find_calls_to_this_idx(self, idx: int, min_required_len: int) -> Tuple[int, Set[int]]:
                def increment_valid_paths(paths): return {x + 1 for x in paths}

                og_end_idx = idx
                entry = self.all_notes_data[og_end_idx]
                if entry.get("type") == "note" and True: #and Channel is not Noise
                
                    # First relative note found: switch to fingerprint matching from next iteration
                    found_first_relative_note = True
                    length = entry.get("length")

                    #Grab all notes of this length (since first relative is unreliable.)
                    self.length_to_indexes_map
                    this_idxes_set = self.length_to_indexes_map.get(length)


                else:
                    # Not a note yet: use length grouping

                    found_first_relative_note = False #If Doing noise, init to True.
                    this_idxes_set = self.idx_to_indexes_map[og_end_idx]

                valid_paths = this_idxes_set.copy()
                
                valid_paths -= self.called_idxes
                valid_paths -= self.riff_depth_layers[-1] #Things at max riff depth cannot call again.

                

                while og_end_idx < len(self.idx_to_indexes_map):

                    non_self_referencing = self.detect_self_ref(valid_paths.copy(), idx, og_end_idx)
                    if not valid_paths & non_self_referencing:
                        break
                    valid_paths &= non_self_referencing

                    og_end_idx += 1
                    valid_paths = increment_valid_paths(valid_paths)

                    if og_end_idx in self.called_idxes:
                        break #Stop when hitting called data
                    next_valid_paths = valid_paths.copy()
                    next_valid_paths -= self.called_idxes
                    next_valid_paths -= self.labeled_idxes





                    entry = self.all_notes_data[og_end_idx]
                    if not found_first_relative_note:
                        if entry.get("type") == "note":
                            # First relative note found: switch to fingerprint matching from next iteration
                            found_first_relative_note = True
                            length = entry.get("length")

                            #Grab all notes of this length (since first relative is unreliable.)
                            self.length_to_indexes_map
                            next_set = self.length_to_indexes_map.get(length)


                        else:
                            # Not a note yet: use length grouping

                            
                            next_set = self.idx_to_indexes_map[og_end_idx]
                    else:
                        # Already found first relative note: always use fingerprint map
                        next_set = self.idx_to_indexes_map[og_end_idx]



                    next_valid_paths &= next_set
                    if next_valid_paths:
                        valid_paths = next_valid_paths
                    else:
                        break    
                    """"
                    NOTE TO CHAT GPT:

                    This is where to collect all the options of wether to use a shorter or a longer riff. (In essence, track when things die off, log number of entires, and the length before the die off)
                    
                    Then, at the end, used the score formula w/ 6 params, and select the best of the options based on the formula.
                    """

                # if len(valid_paths) > 1:
                #     print()
                return og_end_idx, valid_paths



            def handle_new_riff(self, idx: int, og_end_idx: int, valid_paths: Set[int], channel_data):
                self.callable_idxes.update(range(idx, og_end_idx))
                self.labeled_idxes.update({idx, og_end_idx})

                new_riff = channel_data.create_new_riff(start=idx, end=og_end_idx)
                new_called_idxes = set()
                deepest_riff_depth = float("-inf")
                length = og_end_idx - idx
                for call_end in valid_paths:
                    call_start = call_end - length
                    call_range = set(range(call_start, call_end))
                    if call_range & new_called_idxes:
                        continue
                    new_riff.add_index(call_start)
                    new_called_idxes.update(call_range)
                    riff_call_depth = self.pop_called_idxes(call_start, call_end)
                    deepest_riff_depth = max(deepest_riff_depth, riff_call_depth)
                self.deepen_riff_layer(idx, og_end_idx, deepest_riff_depth)
                self.called_idxes.update(new_called_idxes)

            def walk_all_indexes(self, min_required_len: int, channel_data) -> int:
                idx = 0
                max_unprocessed_len = 0
                while idx < len(self.fingerprinted_list):

                    if idx == 68:
                        print()

                    if idx in self.called_idxes:
                        idx += 1
                        continue
                    
                    og_end_idx, valid_paths = self.find_calls_to_this_idx(idx, min_required_len)
                    
                    if not any(entry['type'] == 'note' for entry in all_notes_data[idx:og_end_idx]):
                        idx += 1
                        continue  # Skip this chunk if no notes are present


                    length = og_end_idx - idx
                    if length >= min_required_len:

                        all_notes_data

   

                        # if len(valid_paths) > 1:
                        #     print()
                        self.handle_new_riff(idx, og_end_idx, valid_paths, channel_data)
                        idx = og_end_idx
                    else:
                        max_unprocessed_len = max(max_unprocessed_len, length)
                        idx += 1
                return max_unprocessed_len

            def process(self, channel_data):
                min_required_len = float("inf")
                while min_required_len >= self.minimum_riff_size:
                    max_unprocessed_len = self.walk_all_indexes(min_required_len, channel_data)
                    if max_unprocessed_len >= min_required_len:
                        raise ValueError("Something wasn't processed when it should've been.")
                    min_required_len = max_unprocessed_len
                all_indexes = set(range(len(self.all_notes_data)))
                debug_unused_indexes = all_indexes - self.callable_idxes - self.called_idxes
                double_used = self.callable_idxes & self.called_idxes
                for depth in reversed(range(len(self.riff_depth_layers))):
                    if self.riff_depth_layers[depth]:
                        self.reached_riff_depth = depth
                        break




        def build_riff_index_maps(channel_data: SongData) -> Tuple[
            Dict[int, List[str]],          # idx_to_riffs_starting_here
            Dict[int, List[str]],          # idx_to_riffs_ending_here
            Dict[int, Dict[str, Union[str, int]]]  # riff_calls_by_idx
        ]:
            idx_to_riffs_starting_here: Dict[int, List[str]] = {}
            idx_to_riffs_ending_here: Dict[int, List[str]] = {}
            riff_calls_by_idx: Dict[int, Dict[str, Union[str, int]]] = {}

            def process_riff(riff: RiffData):
                # Map start and end
                idx_to_riffs_starting_here.setdefault(riff.start, []).append(riff.id)
                idx_to_riffs_ending_here.setdefault(riff.end, []).append(riff.id)

                # Register riff calls
                riff_length = riff.end - riff.start
                for call_start in riff.called_indexes:
                    riff_calls_by_idx[call_start] = {
                        "id": riff.id,
                        "end": call_start + riff_length,
                    }

                # Recurse into subriffs, if any
                if hasattr(riff, "subriffs_dict"):
                    for subriff in riff.subriffs_dict.values():
                        process_riff(subriff)

            for riff in channel_data.riffs_dict.values():
                process_riff(riff)

            riff_calls_by_idx = dict(sorted(riff_calls_by_idx.items()))
            return idx_to_riffs_starting_here, idx_to_riffs_ending_here, riff_calls_by_idx


        def build_riff_compressed_sequence(all_notes_data: List[Dict], channel_data: SongData) -> List[Union[Dict, str]]:
            
            def process_note_data_entry(entry: Dict[str,Any], idx: int):
            
                        # === Handlers for each type ===
                    def handle_string(entry, idx):

                        string_value = entry.get("string")

                        if not isinstance(string_value, str):
                            raise TypeError(
                                f"'string' must be a string in 'string' entry at index {idx}, got {type(string_value).__name__}"
                            )

                        #First handle the end of the letter. Then append the string.
                        riff_compressed_seq.append(string_value)


                    def handle_init_header(entry, idx):
                        if not isinstance(entry, dict):
                            raise TypeError(f"Expecteed 'entry' to be a dict in Init_Header at index {idx}, got {type(entry).__name__}")
                        
                        riff_compressed_seq.append(entry)


                    def handle_note(entry, idx):

                        riff_compressed_seq.append(entry) 

                    def handle_kick_sfx(entry,idx):
                        if len(entry) != 2:
                            raise Exception(f"[ERROR] Unimplemented Kick Type at index {idx}: {entry}")
                        riff_compressed_seq.append(".byte Kick_SFX ;$f2?") #[15, 2])


                    def handle_rest(entry, idx):
                        length = entry.get("length")
                        riff_compressed_seq.append([length, 0]) #the array [1,0] means the byte $10

                        if True: #Validation
                            if length is None:
                                raise ValueError(f"Missing 'length' in rest entry at index {idx}: {entry}")
                            elif not isinstance(length, int):
                                raise TypeError(f"'length' must be an int in rest entry at index {idx}, got {type(length).__name__}")
                            elif not (0 <= length <= 15):
                                raise ValueError(f"Invalid rest nibble {length} at index {idx}")                

                    def handle_Env_Change(entry, idx):
                        new_env_pointer = entry.get("new_env_pointer")
                        riff_compressed_seq.append(f"Env_Change {new_env_pointer}")
                        

                        if not isinstance(new_env_pointer, int):
                            raise TypeError(f"'new_env_pointer' must be an int in Env_Change at index {idx}, got {type(new_env_pointer).__name__}")
                        
                    def handle_repeat_raw_dict(entry, idx):
                        repeat_id = entry.get("id")
                        count = entry.get("count")
                        first_instance = entry.get("first_instance")

                        index = len(riff_compressed_seq) #NOT CONFIDENT

                        repeat_entry = {
                            "type": "Repeat",
                            "length": "Unknown",
                            "count": count,
                            "id": repeat_id,
                            "first_instance": first_instance,
                            "index": index #Index of Riff Compressed?
                        }
                        """
                        This sets the Riff Call. 
                        """

                        riff_compressed_seq.append(repeat_entry)

                        if True:  # Validation
                            if repeat_id is None:
                                raise ValueError(f"Missing 'id' in repeat entry at index {idx}: {entry}")
                            if not isinstance(repeat_id, str):
                                raise TypeError(f"'id' must be a string in repeat entry at index {idx}, got {type(repeat_id).__name__}")
                            
                            if count is None:
                                raise ValueError(f"Missing 'count' in repeat entry at index {idx}: {entry}")
                            if not isinstance(count, int):
                                raise TypeError(f"'count' must be an int in repeat entry at index {idx}, got {type(count).__name__}")

                            if not isinstance(first_instance, bool):
                                raise TypeError(f"'first_instance' must be a bool in repeat entry at index {idx}, got {type(first_instance).__name__}")
                        return


                    nonlocal riff_compressed_seq

                    # Fetch the entry from all_notes_data
                    
                    entry_type = entry.get("type")  # Get the type of the entry

                    # Dispatch table mapping types to their corresponding handler functions
                    type_handlers = {
                        "string": handle_string,
                        "Init_Header": handle_init_header,
                        "note": handle_note,
                        "rest": handle_rest,
                        "Env_Change": handle_Env_Change,
                        "repeat": handle_repeat_raw_dict,
                        "Kick SFX": handle_kick_sfx,
                    }

                    # Call the appropriate handler based on the entry type
                    handler = type_handlers.get(entry_type)
                    if handler:
                        handler(entry, idx)
                    else:
                        raise ValueError (f"Unimplimented note_data_type:{entry_type}")
                    return
                

            
            idx_to_riffs_starting_here, idx_to_riffs_ending_here, riff_calls_by_idx = build_riff_index_maps(channel_data)

            riff_compressed_seq = []
            last_ptr_prefix = None
            idx = 0
            
            while idx < len(all_notes_data):
                entry = all_notes_data[idx]
                ptr = entry.get("ptr")
                ptr_prefix = ptr.split("-")[0] if ptr else None


                # 1. Riff ends
                if idx in idx_to_riffs_ending_here:
                    for riff_id in idx_to_riffs_ending_here[idx]:
                        riff_compressed_seq.append(f"; end @_{riff_id}")

                # 2. Visual marker for ptr prefix change
                if ptr_prefix and ptr_prefix != last_ptr_prefix:
                    riff_compressed_seq.append(f";{ptr_prefix}")
                    last_ptr_prefix = ptr_prefix

                # 4. Riff starts
                if idx in idx_to_riffs_starting_here:
                    for riff_id in idx_to_riffs_starting_here[idx]:
                        riff_compressed_seq.append(f"@_{riff_id}:")

                # 5. Riff calls
                if idx in riff_calls_by_idx:
                    call = riff_calls_by_idx[idx]  # this is a dict, not a list
                    riff_entry = {
                        "type": "Riff",
                        "id": call["id"],
                        "index": idx,
                        "length": call["end"] - idx
                    }
                    riff_compressed_seq.append(riff_entry)
                    idx = call["end"]
                    continue  # Skip raw entry
                else:
                    process_note_data_entry(entry, idx)
                    idx += 1

            return riff_compressed_seq




        #=== Major Main ===
        fingerprinted_list = generate_fingerprints()
        idx_to_indexes_map, fp_groups = build_idx_to_indexes_map(fingerprinted_list)
        length_to_indexes_map = build_note_length_index_map(fingerprinted_list)
        #brute_forcer(fingerprinted_list, idx_to_indexes_map)


        bf = RiffBruteForcer(fingerprinted_list, idx_to_indexes_map, length_to_indexes_map, all_notes_data)
        bf.process(channel_data)

        riff_compressed_seq = build_riff_compressed_sequence(all_notes_data, channel_data)

        return riff_compressed_seq
    

#New one will need to read the stuff, and do somethign very simular to the old annotate and unwrap riffs.

    def is_normal_riff(riff_id: str) -> bool:
        # True if riff_id starts with a digit (normal riff or subriff like '0' or '0a')
        return bool(re.match(r'^\d', riff_id))

    def is_subriff(riff_id: str) -> bool:
        # True if riff_id starts with digit and has trailing letters (like '0a')
        return bool(re.match(r'^\d+[a-zA-Z]+$', riff_id))

    def is_letter_riff(riff_id: str) -> bool:
        # True if riff_id starts with a letter (like 'A', 'B')
        return bool(re.match(r'^[a-zA-Z]+$', riff_id))




    def annotate_and_unwrap_riffs(
        best_riff_dict: List[Dict[str, Any]],
        minor_collisions: List[Dict[str, Any]],
        all_notes_data: List[Dict[str, Any]],
    ) -> List[Any]:

        def init_numbered_riffs() -> None:
            nonlocal best_riff_dict
            formatted_riff_set = []
            for riff_idx, riff in enumerate(best_riff_dict):
                collision_info = minor_collisions[riff_idx]

                if collision_info:
                    og_idx = next(iter(collision_info["collisions_by_index"]))
                else:
                    og_idx = "Unknown"

                formatted_riff_set.append({
                    "og_idx": og_idx,
                    **riff,
                    
                })

            best_riff_dict = formatted_riff_set
            return best_riff_dict


        def map_idx_to_riff_starts():
            idx_to_riffs_starting_here = {}  # maps start_idx to list of riff dicts
            for riff_id, riff in enumerate(best_riff_dict):
                start_indexes = riff.get("indexes")
                if start_indexes:
                    for start_idx in start_indexes:
                        idx_to_riffs_starting_here.setdefault(start_idx, []).append({
                            "riff_id": riff_id,
                            "riff": riff
                        })
            return idx_to_riffs_starting_here


        def process_note_data_entry(idx: int):
            




                # === Handlers for each type ===
            def handle_string(entry, idx):

                string_value = entry.get("string")

                if not isinstance(string_value, str):
                    raise TypeError(
                        f"'string' must be a string in 'string' entry at index {idx}, got {type(string_value).__name__}"
                    )

                #First handle the end of the letter. Then append the string.
                riff_compressed_seq.append(string_value)


            def handle_init_header(entry, idx):
                if not isinstance(entry, dict):
                    raise TypeError(f"Expecteed 'entry' to be a dict in Init_Header at index {idx}, got {type(entry).__name__}")
                
                riff_compressed_seq.append(entry)


            def handle_note(entry, idx):

                riff_compressed_seq.append(entry) 

            def handle_kick_sfx(entry,idx):
                if len(entry) != 2:
                    raise Exception(f"[ERROR] Unimplemented Kick Type at index {idx}: {entry}")
                riff_compressed_seq.append([15, 2])


            def handle_rest(entry, idx):
                length = entry.get("length")
                riff_compressed_seq.append([length, 0]) #the array [1,0] means the byte $10

                
                if length is None:
                    raise ValueError(f"Missing 'length' in rest entry at index {idx}: {entry}")
                elif not isinstance(length, int):
                    raise TypeError(f"'length' must be an int in rest entry at index {idx}, got {type(length).__name__}")
                elif not (0 <= length <= 15):
                    raise ValueError(f"Invalid rest nibble {length} at index {idx}")                

            def handle_Env_Change(entry, idx):
                new_env_pointer = entry.get("new_env_pointer")
                riff_compressed_seq.append(f"Env_Change {new_env_pointer}")
                

                if not isinstance(new_env_pointer, int):
                    raise TypeError(f"'new_env_pointer' must be an int in Env_Change at index {idx}, got {type(new_env_pointer).__name__}")
                
            def handle_repeat_raw_dict(entry, idx):
                repeat_id = entry.get("id")
                count = entry.get("count")
                first_instance = entry.get("first_instance")

                index = len(riff_compressed_seq) #NOT CONFIDENT

                repeat_entry = {
                    "type": "Repeat",
                    "length": "Unknown",
                    "count": count,
                    "id": repeat_id,
                    "first_instance": first_instance,
                    "index": index
                }
                """
                This sets the Riff Call. 
                """

                riff_compressed_seq.append(repeat_entry)

                if True:  # Validation
                    if repeat_id is None:
                        raise ValueError(f"Missing 'id' in repeat entry at index {idx}: {entry}")
                    if not isinstance(repeat_id, str):
                        raise TypeError(f"'id' must be a string in repeat entry at index {idx}, got {type(repeat_id).__name__}")
                    
                    if count is None:
                        raise ValueError(f"Missing 'count' in repeat entry at index {idx}: {entry}")
                    if not isinstance(count, int):
                        raise TypeError(f"'count' must be an int in repeat entry at index {idx}, got {type(count).__name__}")

                    if not isinstance(first_instance, bool):
                        raise TypeError(f"'first_instance' must be a bool in repeat entry at index {idx}, got {type(first_instance).__name__}")
                return


            nonlocal riff_compressed_seq

            # Fetch the entry from all_notes_data
            entry = all_notes_data[idx]
            entry_type = entry.get("type")  # Get the type of the entry

            # Dispatch table mapping types to their corresponding handler functions
            type_handlers = {
                "string": handle_string,
                "Init_Header": handle_init_header,
                "note": handle_note,
                "rest": handle_rest,
                "Env_Change": handle_Env_Change,
                "repeat": handle_repeat_raw_dict,
                "Kick SFX": handle_kick_sfx,
            }

            # Call the appropriate handler based on the entry type
            handler = type_handlers.get(entry_type)
            if handler:
                handler(entry, idx)
            else:
                raise ValueError (f"Unimplimented note_data_type:{entry_type}")
            return
        

        def process_riff(idx, selected_riff_info):
            nonlocal unwrapping_riffs

            # Step 1: Use the riff with the longest length
            selected_riff_info = max(selected_riff_info, key=lambda r: r["riff"].get("length", 0))
            
            riff_id = selected_riff_info["riff_id"]
            riff = best_riff_dict[riff_id]

            length = riff.get("length", 0)
            if length <= 2:
                raise ValueError(f"Invalid riff length: {length}")

            # Check if the riff is being unwrapped at its origin
            if riff.get("og_idx") in ("Unknown", idx):
                riff["og_idx"] = idx

                idx, unwrapping_riffs = unwrap_riff_here(idx, riff_id, unwrapping_riffs)
 
                advance = 0
            else:
                # Create a riff call
                riff_entry = {
                    "type": "Riff",
                    "length": length,
                    "id": riff_id,
                    "index": idx,
                }
                riff_compressed_seq.append(riff_entry)

                idx += length
                advance = length

            return idx, advance, unwrapping_riffs


        def unwrap_riff_here(idx: int, riff_id: int, unwrapping_riffs: List[int]):
            riff_compressed_seq.append("")
            riff_compressed_seq.append(f"@_{riff_id}:")

            riff = best_riff_dict[riff_id]
            riff_length = riff.get("length", 0)

            # Enter a new depth
            unwrapping_riffs.append({"riff_id": riff_id, "sub_idx": 0, })

            while riff_id in [layer["riff_id"] for layer in unwrapping_riffs]:  # Loop until this riff is no longer active

                if unwrapping_riffs[-1]["sub_idx"] > riff_length:
                    raise ValueError (f"Riff ended after its fingerprinted_data. Was a Minor Collision mis-handled?")
                        #This may happen w/ the Minor Collisions.

                # Collect all active riff_ids
                unwrapping_riff_ids = {layer["riff_id"] for layer in unwrapping_riffs}

                all_riffs_here = idx_to_riffs_starting_here.get(idx, [])
                sub_riffs = [r for r in all_riffs_here if r["riff_id"] not in unwrapping_riff_ids]

                if sub_riffs:
                    selected_riff_info = sub_riffs
                    idx, advance, unwrapping_riffs = process_riff(idx, selected_riff_info)

                else:
                    process_note_data_entry(idx)
                    idx += 1
                    advance = 1

                # Advance all currently unwrapping riffs.

                layers_to_remove = []
                for layer in reversed(unwrapping_riffs): #reversed in the hope the order is always backward.
                    layer_riff_id = layer["riff_id"]
                    layer_riff_length = best_riff_dict[layer_riff_id].get("length", 0)
                    layer["sub_idx"] += advance

                    if layer["sub_idx"] == layer_riff_length:

                        layers_to_remove.append(layer)
                        riff_compressed_seq.append(f"; end @_{layer_riff_id}")

                    elif layer["sub_idx"] > layer_riff_length:
                        raise ValueError(f"Layer exceeded riff length: riff_id {layer['riff_id']}. Was a Minor Collision mishandled?")

                # Remove them after processing.
                if len(layers_to_remove) > 1:
                    print(f"[WARN] did the riffs: '{layers_to_remove}' end in the correct order? Not well-confirmed")

                for layer in reversed(layers_to_remove):
                    unwrapping_riffs.remove(layer)
                            
            return idx, unwrapping_riffs

        #=== Major Main ===
        #Args:
            #best_riff_dict: List[Dict[str, Any]],
            #minor_collisions: List[Dict[str, Any]],
            #all_notes_data: List[Dict[str, Any]],
            
            #-> riff_compressed_seq: List[Any]
        best_riff_dict = init_numbered_riffs()
        idx_to_riffs_starting_here = map_idx_to_riff_starts()
        idx = 0
        unwrapping_riffs = []

    
        while idx < len(all_notes_data):
            riffs_here = idx_to_riffs_starting_here.get(idx)
            if riffs_here:

                selected_riff_info = riffs_here
                idx, advance, unwrapping_riffs = process_riff(idx, selected_riff_info)
                #idx += len(riff)

            else:
                process_note_data_entry(idx)
                idx += 1

        return riff_compressed_seq, best_riff_dict





    def filter_unused_riffs(riff_compressed_seq: List[Any], best_riff_dict: List[Dict[str, Any]]) -> Dict[str, Dict[str, Any]]:
        riff_index_map = {}    # int riff_id → list of actual positions in compressed seq
        used_riff_dict = {}    # final result

        # Step 1: Scan riff_compressed_seq to populate riff_index_map and riff_og_idx_map
        for idx, item in enumerate(riff_compressed_seq):
            if isinstance(item, dict) and item.get("type") in ("Riff", "Repeat"):
                riff_id = item.get("id")
                riff_index_map.setdefault(riff_id, []).append(idx)


            elif isinstance(item, str) and item.startswith("@_") and item.endswith(":"):
                riff_id = item[2:-1]  # Extract "A" or "12" from "@_A:" or "@_12:"

                # Find the corresponding end marker
                end_marker = f"; end @_{riff_id}"
                try:
                    end_idx = riff_compressed_seq.index(end_marker, idx)
                    length = end_idx - idx  # Pythonic exclusive range
                except ValueError:
                    raise ValueError (f"Unable to find end marker for riff: '{riff_id}")

                # Initialize the entry for this riff
                used_riff_dict.setdefault(riff_id, {})
                used_riff_dict[riff_id]["og_idx"] = idx
                used_riff_dict[riff_id]["length"] = length


        for riff_id, riff_data in enumerate(best_riff_dict):
            riff_id_str = str(riff_id)
            og_entry = used_riff_dict.get(riff_id_str)
            used_indexes = riff_index_map.get(riff_id)

            if og_entry is None and used_indexes:
                # Indexes found but no original fingerprinted_data in used_riff_dict
                raise ValueError(f"[FATAL] {riff_id} was called w/o original fingerprinted_data.")

            elif og_entry and not used_indexes:

                print (f"[WARN] A Riff went unused, despite many rounds of filtering.")

                og_idx = og_entry.get("og_idx")
                length = og_entry.get("length")

                

                # Delete End Marker
                end_marker = f"; end @_{riff_id}"
                try:
                    end_idx = riff_compressed_seq.index(end_marker, og_idx)
                    riff_compressed_seq[og_idx] = "" #start
                    riff_compressed_seq[end_idx] = ""
                except ValueError:
                    raise ValueError (f"Unable to find end marker for riff: '{riff_id}")

                del used_riff_dict[riff_id_str]
                continue

            elif og_entry and used_indexes:
                # Both exist: merge indexes including og_idx, preserve other riff_data
                entry = og_entry.copy()
                combined_indexes = used_indexes + [og_entry.get("og_idx")]
                entry["indexes"] = sorted(combined_indexes)
                used_riff_dict[riff_id_str] = entry

        used_riff_dict = dict(sorted(used_riff_dict.items(), key=lambda item: item[0]))

        for riff_id, indexes in riff_index_map.items():
            if isinstance(riff_id, str) and riff_id.isalpha():
                og_entry = used_riff_dict.get(riff_id)
                
                combined_indexes = sorted(indexes + [og_entry["og_idx"]])
                og_entry["indexes"] = combined_indexes


        used_riff_dict = dict(sorted(used_riff_dict.items(), key=lambda item: item[0]))
        return used_riff_dict


    def simplify_riff_data(best_riff_dict: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        pruned_set = []
        for riff in deepcopy(best_riff_dict):
            pruned = {
                "indv_score": riff.get("indv_score"),
                "score": riff.get("score"),
                "length": riff.get("length"),
                "indexes": riff.get("indexes"),
                "seq": riff.get("seq"),
            }
            pruned_set.append(pruned)

        return pruned_set


    def process_raw_bytes(unformated_byte_seq: List[Any],) -> List[str]:

        def count_raw_bytes_in_range(start_idx: int, end_idx: int) -> int:
            #counts the number of bytes represented by unformated_byte_seq[start_idx:end_idx].
            total = 0
            for item in unformated_byte_seq[start_idx:end_idx]:
                if isinstance(item, list):
                    total += 1
                elif isinstance(item, dict):
                    total += 2
                    # if end_idx != len(unformated_byte_seq) or start_idx != 0:
                    #     print (f"Miscounts if {item} is not a Short Riff Call")

                elif isinstance(item, str):
                    stripped = item.strip()
                    if not stripped or stripped.startswith(";") or stripped.startswith("@") or stripped.endswith(":"):
                        continue
                    elif stripped.startswith("Shift_Pitch"):
                        total += 1
                    elif stripped.startswith("Set_Pitch"):
                        total += 2
                    elif stripped.startswith("Env_Change"):
                        total += 1 
                    elif stripped.startswith(".byte"):
                        # count the number of "$" hexadecimal values using regex
                        matches = re.findall(r"\$\w{1,2}", stripped)
                        total += len(matches)
                    else:
                        raise ValueError (f"Unimplimented String Type: '{stripped}'")
                else:
                    raise TypeError (f"Unimplimented Type: {item}")
            return total

        def handle_riff_call(riff_call: Dict[str, Any],output_lines: List[str],) -> str:
            riff_id = riff_call["id"]
            tag = f"@_{riff_id}:"
            end_tag = f"; end @_{riff_id}"

            try:
                start_idx = output_lines.index(tag)
                end_idx = output_lines.index(end_tag)
                riff_length = count_raw_bytes_in_range(start_idx, end_idx)
                riff_line = f"Riff {riff_length}, @_{riff_id}" 
            except ValueError:
                riff_length = "Still Unknown"
                riff_line = riff_call.copy()
                riff_line['length'] = "Still Unknown"
                #This happens w/ Minor collisions where the first entry shows up after.
                #Just append the dict. I'll clean it up later.
            return riff_line, riff_length

        
        def combine_nibbles(nibble_pair: List[int]) -> int:

            hi = nibble_pair[0]
            low = nibble_pair[1]
            byte = (hi << 4) | low

            if (len(nibble_pair) != 2 or not all(0 <= nib <= 15 for nib in nibble_pair)):
                raise ValueError(f"Invalid nibble pair: {nibble_pair}")
            return byte

        def should_start_new_line(byte_val: int, current_line_len: int) -> bool:
            return current_line_len < 4
        

        def format_byte_line(byte_list: List[int]) -> str:
            hex_values = ", ".join(f"${b:02x}" for b in byte_list)
            return f".byte {hex_values}"







        def handle_repeat(repeat_data):
            def repeat_line(repeat_count, targets_length):
                if targets_length > 31: #Assuming the 5bit Short-Call Opperand.
                    line = f'Repeat {repeat_count}, "Long"'
                else:
                    line = f'Repeat {repeat_count}, "Short"'

                return line
            
            riff_line, riff_length = handle_riff_call(repeat_data, output_lines)
            count = repeat_data["count"]
            riff_id = repeat_data["id"]
            first_instance = repeat_data["first_instance"]
            
            if count < 0:
                raise ValueError("ERROR: Repeats cannot be negetive.")
            

            """
            Lmao, I'm just gonna let the repeat have the 0 case mean read next byte for number of repeats.
            """
            

            if count <= 8:
                # Simple case: single repeat
                repeats_og = True
                output_lines.append(riff_line)
                output_lines.append(repeat_line(count, riff_length))

            
            elif count <= 18 and count % 2 == 1:
                print(f"Warning: Repeat count is Large")
                # Odd counts ≤ 18, can always be built w/ repeat + 1 call
                repeat_count = (count // 2) - 1
                repeats_og = True

                output_lines.append(f"@_{riff_id}_{idx}") #IDX is just a number guarenteed to be unique.
                output_lines.append(riff_line) #+1
                output_lines.append(repeat_line(repeat_count, riff_length)) #*4-8

                extra_riff_length = 4 if riff_length > 31 else 3 
                extra_riff_line = f"Riff {extra_riff_length}, @_{riff_id}_{idx}"
                output_lines.append(extra_riff_line)

            elif count <= 18 and count % 2 == 0 and first_instance:   
                print(f"Warning: Repeat count is large")  
                #output_lines(raw_riff_data) 
                output_lines.append(riff_line) #+1          

                extra_riff_length = riff_length+3 if riff_length > 31 else riff_length+2
                extra_riff_line = f"Riff {extra_riff_length}, @_{riff_id}"
                output_lines.append(extra_riff_line)
                
                repeat_count = (count // 2) - 1
                output_lines.append(repeat_line(repeat_count, riff_length+2)) #2*4-8

            elif count <= 18 and count % 2 == 0 and not first_instance:
                print(f"WARNING: Repeat count is Extremely Large")
                output_lines.append(riff_line) #+1  
                output_lines.append(riff_line) #w/o first instance, it needs the extra one to get it going.
                
                extra_riff_length = riff_length+3 if riff_length > 31 else riff_length+2
                extra_riff_line = f"Riff {extra_riff_length}, @_{riff_id}"
                output_lines.append(extra_riff_line)
                
                repeat_count = (count // 2) - 1
                output_lines.append(repeat_line(repeat_count, 6)) #2*4-8
            else:
                raise ValueError(f"Unimplemented Repeat count: {count} (Needs to build a general formula.)")




        #=== Major Main ===
        output_lines = []
        current_line = []

        for idx, item in enumerate(unformated_byte_seq):
            if isinstance(item, dict):

                dict_type = item["type"]
                if dict_type == "Riff":
                    riff_line, riff_length = handle_riff_call(item, output_lines)
                    output_lines.append(riff_line)

                elif dict_type == "Repeat":
                    count = item["count"]
                    if count == 0:
                        riff_line, riff_length = handle_riff_call(item, output_lines)
                        output_lines.append(riff_line) #Identical to a Riff Call

                    else:
                        handle_repeat(item)


                else:
                    raise TypeError (f"Invalid dict type in item: '{item}'")


                    
                
            elif isinstance(item, str):
                # Flush any in-progress byte line first
                if current_line:
                    output_lines.append(format_byte_line(current_line))
                    current_line = []
                output_lines.append(item)



            elif isinstance(item, list):
                byte = combine_nibbles(item)
                current_line.append(byte)
                if should_start_new_line(byte, len(current_line)):
                    output_lines.append(format_byte_line(current_line))
                    current_line = []
            else:
                raise ValueError(f"Unsupported type in unformated_byte_seq: {type(item)}")
        
        # Final flush
        if current_line:
            output_lines.append(format_byte_line(current_line))


        for i, line in enumerate(output_lines):
            if isinstance(line, dict):
                if line["type"] == "Repeat":
                    raise TypeError(f'Didnt expect Repeats here')

                # Resolve Riff size now.
                riff_line, riff_length = handle_riff_call(line, output_lines)

                if riff_length == "Still Unknown":
                    raise ValueError(f'Riff "{line}" has unknowable length. Likely an invalid Riff')
                else:
                    # Replace the original dict line with the processed riff_line
                    output_lines[i] = riff_line

        return output_lines



    def count_bytes_in_output_lines(output_lines: list[str]) -> int:
        total = 0

        for line in output_lines:
            if isinstance(line, dict):
                raise TypeError (f"Need to resolve Riffs/Repeats prior to this function")

            
            stripped = line.strip()
            if not stripped or stripped.startswith(";") or stripped.endswith(":"):
                continue  # Skip empty lines, comments, and labels

            elif stripped.startswith(".byte"):
                if "Loop" in stripped:
                    total += 1
                else:
                    # count number of hex values like $xx
                    matches = re.findall(r"\$\w{1,2}", stripped)
                    total += len(matches)

            elif stripped.startswith(("Shift_Pitch", "Env_Change", "Repeat")):
                total += 1
                
            elif stripped.startswith("Set_Pitch"):
                total += 2

            elif stripped.startswith("Riff"):
                # Match pattern: Riff number, label
                match = re.match(r"Riff\s+(\d+),", stripped)
                if not match:
                    raise ValueError(f"Malformed Riff line: {stripped}")
                count = int(match.group(1))
                total += 2 if count <= 31 else 3
                if count <= 31:
                    print ("[NOTE] Long Riffs keep changing absolute size.")

            else:
                raise ValueError(f"Unimplemented line type: '{stripped}'")

        return total
 
    #=== Section Main ===


    riff_compressed_seq = brute_force_forward_riffs(all_notes_data) 

    print()
    unformatted_byte_seq = calculate_base_pitches(riff_compressed_seq, channel_data, all_notes_data)

    output_lines = process_raw_bytes(unformatted_byte_seq,)
    file_size = count_bytes_in_output_lines(output_lines)
    # if file_size > 256:
    #     raise ValueError (f"Song is too big.")
    if file_size > 200:
        print (f"[WARN] file size of {file_size}. Its Quite large.")
    return output_lines, file_size











    # all_repeated_sequences = OLD_lcp_extract_all_repeated_sequences(all_notes_data)
    # best_riff_dict, minor_collisions = build_best_riff(all_repeated_sequences, all_notes_data)
    # riff_compressed_seq, best_riff_dict = annotate_and_unwrap_riffs(best_riff_dict, minor_collisions, all_notes_data)
    
    # used_riff_dict = filter_unused_riffs(riff_compressed_seq, best_riff_dict)

    # unformatted_byte_seq = calculate_base_pitches(riff_compressed_seq, used_riff_dict, all_notes_data)
    
    # final_used_riff_dict = filter_unused_riffs(unformatted_byte_seq, used_riff_dict)

    # if used_riff_dict != final_used_riff_dict:
    #     print (f"[NOTE] Could prune some of the unneeded strings in the output lines")




    # output_lines = process_raw_bytes(unformatted_byte_seq,)
    # file_size = count_bytes_in_output_lines(output_lines)
    # # if file_size > 256:
    # #     raise ValueError (f"Song is too big.")
    # if file_size > 200:
    #     print (f"[WARN] file size of {file_size}. Its Quite large.")
    # return output_lines, file_size





