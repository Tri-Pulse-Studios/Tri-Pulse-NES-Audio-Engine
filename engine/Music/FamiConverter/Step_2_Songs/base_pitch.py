from utils.riff_class import UNINIT, NO_DATA, RiffData, SongData
import re


from typing import List, Dict, Any, Callable, Tuple, Union, Optional, Set
from collections import defaultdict, deque
from dataclasses import dataclass, field
from utils import helpers as h

def calculate_base_pitches(
    riff_compressed_seq: List[Any], 
    channel_data: SongData, #used_riff_dict: List[Dict[str, Any]], 
    all_notes_data: List[Dict[str, Any]]
) -> List[Any]:


    def OLD_list_colliding_groups(used_riff_dict: dict[str, dict]) -> list[dict]:
        """
        Detect all groups of overlapping original riff instances (og_idx).
        For each collision group, record the collision range and sub-riffs
        whose call indexes fall inside that range.
        """
        all_ids = list(used_riff_dict.keys())
        collisions = []

        # Step 1: Build list of (id, og_idx, length)
        spans = []
        for rid in all_ids:
            riff = used_riff_dict.get(rid)
            if riff and "og_idx" in riff and "length" in riff:
                start = riff["og_idx"]
                end = start + riff["length"]
                spans.append((rid, start, end))

        # Step 2: Group overlapping spans
        visited = set()
        for i, (id_a, start_a, end_a) in enumerate(spans):
            if id_a in visited:
                continue

            # Start a new group
            group = {id_a}
            range_start = start_a
            range_end = end_a

            # Expand group with overlapping riffs
            changed = True
            while changed:
                changed = False
                for id_b, start_b, end_b in spans:
                    if id_b in group:
                        continue
                    # Check for partial overlap, but not full containment
                    if start_b < range_end and end_b > range_start:
                        # Skip full containment cases (either direction)
                        if (range_start <= start_b and range_end >= end_b) or (start_b <= range_start and end_b >= range_end):
                            continue
                        group.add(id_b)
                        range_start = min(range_start, start_b)
                        range_end = max(range_end, end_b)
                        changed = True


            visited.update(group)

            # Step 3: Find sub-riffs (exclude group members)
            sub_riffs = []
            for rid in all_ids:
                if rid in group:
                    continue  # Skip riffs that are already part of the collision group

                riff = used_riff_dict.get(rid)
                if not riff:
                    continue

                for idx in riff.get("indexes", []):
                    if range_start <= idx < range_end:
                        sub_riffs.append(rid)
                        break  # Only need to match once

            # Record this collision group
            collisions.append({
                "colliding_ids": set(group),
                "collision_start": range_start,
                "collision_end": range_end,
                "sub_riffs": set(sub_riffs)
            })
        # Remove any group that is a subset of another
        filtered = []
        for c in collisions:
            group = c["colliding_ids"]
            if not any(group < other["colliding_ids"] for other in collisions):
                filtered.append(c)

        collisions = filtered
        return collisions




    def list_colliding_groups_from_song(channel_data: SongData) -> list[dict]:
        """
        Detect overlapping original riff instances (including subriffs) from SongData.
        Returns a list of collision groups with collision range and sub-riffs
        whose call indexes fall inside that range.
        """

        # Helper to collect all riffs (flatten tree into list)
        def collect_all_riffs(riffs: dict[str, RiffData]) -> list[RiffData]:
            all_riffs = []

            def recurse(riff: RiffData):
                all_riffs.append(riff)
                if hasattr(riff, 'subriffs_dict'):
                    for sub in riff.subriffs_dict.values():
                        recurse(sub)

            for riff in riffs.values():
                recurse(riff)

            return all_riffs

        all_riffs = collect_all_riffs(channel_data.riffs_dict)
        spans = [(riff.id, riff.start, riff.end) for riff in all_riffs]
        collisions = []
        visited = set()

        # Group overlapping spans
        for i, (id_a, start_a, end_a) in enumerate(spans):
            if id_a in visited:
                continue

            group = {id_a}
            range_start = start_a
            range_end = end_a

            changed = True
            while changed:
                changed = False
                for id_b, start_b, end_b in spans:
                    if id_b in group:
                        continue
                    if start_b < range_end and end_b > range_start:
                        if (range_start <= start_b and range_end >= end_b) or (start_b <= range_start and end_b >= range_end):
                            continue
                        group.add(id_b)
                        range_start = min(range_start, start_b)
                        range_end = max(range_end, end_b)
                        changed = True

            visited.update(group)

            # Find sub-riffs whose call indexes fall inside the range
            sub_riffs = []
            for riff in all_riffs:
                if riff.id in group:
                    continue
                if any(range_start <= idx < range_end for idx in riff.called_indexes):
                    sub_riffs.append(riff.id)

            collisions.append({
                "colliding_ids": set(group),
                "collision_start": range_start,
                "collision_end": range_end,
                "sub_riffs": set(sub_riffs)
            })

        # Remove subset groups
        filtered = []
        for c in collisions:
            group = c["colliding_ids"]
            if not any(group < other["colliding_ids"] for other in collisions):
                filtered.append(c)

        return filtered






    class SegmentLeaf:
        def __init__(
            self,
            start: int,
            length: int,
            active_ids: Set[str],
            note_pitches: Optional[List[int]],
            entries: Optional[List[Union[str, Dict[str, Any]]]] = UNINIT,
            
        ):
            if not active_ids:
                active_ids = set("r")

            self.start = start
            self.length = length
            self.active_ids = active_ids
            self.entries: List[Union[str, Dict[str, Any]]] = entries if entries is not None else []
            
            if not note_pitches or note_pitches in (UNINIT,NO_DATA):
                print()

            self.note_pitches: List[int] = note_pitches 
            self._base_pitch = UNINIT

        def __repr__(self):
            base = (
                f"SegmentLeaf(start={self.start}, length={self.length}, "
                f"active_ids={sorted(self.active_ids)}, "
                f"entries={len(self.entries)}, note_pitches={self.note_pitches}"
            )
            if hasattr(self, "_base_pitch"):
                base += f", bp_shift={self._base_pitch}"
            return base + ")"


        def get_base_pitch(self) -> Optional[Set[int]]:
            return getattr(self, '_base_pitch', UNINIT)

        def set_base_pitch(self, shift: Optional[int]):
            if hasattr(self, "_base_pitch"):
                if self._base_pitch is not UNINIT:
                    print(f"leaf bp_shift should only be written once. Existing: {self._base_pitch}, New: {shift}")
            self._base_pitch = shift


        def update_base_pitch(self, new_bp: Optional[int]):
            old_bp = self._base_pitch
            if old_bp is UNINIT:
                raise ValueError (f"Use set_base_pitch first time.")
            elif old_bp is not NO_DATA:

                raise NotImplementedError (f"Currently see no reason to change the bp of a leaf.")
            elif old_bp is NO_DATA:
                self._base_pitch = new_bp
            print (f'[NOTE] Updated bp from {old_bp} to {new_bp} of leaf: {self}')
            


    class SegmentCall:
        def __init__(self, start: int, entry: dict, active_ids: set[str]):
            self.start = start
            self.called_id = str(entry.get("id"))
            self.first_pitch = NO_DATA
            self._base_pitch = UNINIT
            self.active_ids = active_ids

            type = entry.get("type")
            if type == "Repeat":
                tag_dict = {'type': 'string', 'string': f"@_{self.called_id}:"}
                og_index = all_notes_data.index(tag_dict) #find the @_id Dict
            elif type == "Riff":
                og_index = entry.get("index")
            
            for data_entry in all_notes_data[og_index:]:  # Find the pitch from the all_notes_data list.
                if isinstance(data_entry, dict) and data_entry.get("type") == "note":
                    self.first_pitch = data_entry.get("pitch_abs")
                    break
            else:
               raise TypeError


            if self.first_pitch is NO_DATA:
                print(f"[WARN] Riff found no first pitch. Is it repeated rests?")

        def set_base_pitch(self, bp: Optional[int]):
            if hasattr(self, "_base_pitch"):
                if self._base_pitch is not UNINIT:
                    print("ERROR")
                    #raise ValueError(f"base shift already set to {self._base_pitch}")
            self._base_pitch = bp

        def get_base_pitch(self) -> Optional[int]:
            if not hasattr(self, "_base_pitch"):
                return UNINIT
            return self._base_pitch

        def __repr__(self):
            parts = [
                f"start={self.start}",
                f"called_id='{self.called_id}'",
                f"first_pitch={self.first_pitch}",
            ]
            if hasattr(self, "_base_pitch"):
                parts.append(f"bp_shift={self._base_pitch}")
            return f"SegmentCall({', '.join(parts)})"


    class RiffInstance:
        def __init__(self, leaves, first_leaf_index, og_first_pitch, call_indexes):
            self.leaves = leaves
            self.first_leaf_index = first_leaf_index
            self.call_indexes = UNINIT #call_indexes  #I'm not how this is used, but can grab the data from the SongData

            self.og_first_pitch = og_first_pitch
            self._exit_shift = UNINIT



        def __repr__(self):
            return (
                f"RiffInstance(og_idx={self.first_leaf_index}, "
                f"idxes={self.call_indexes}, "
                f"exit_shift={self.get_exit_shift()}, "
                f"og_first_pitch={self.og_first_pitch}"
                f"leaves=[{len(self.leaves)}])"
            )

        def get_exit_shift(self) -> int:
            return self._exit_shift

        def update_exit_shift(self, shift_change: int):
            self._exit_shift -= shift_change #TODO: I TRIED += TRY -=
            return self._exit_shift

        def init_first_pitch(self):
            if self.leaves:
                leaf_start = self.leaves[0].start
                for entry in riff_compressed_seq[leaf_start:]:
                    if isinstance(entry, dict) and entry.get("type") == "note":
                        self.og_first_pitch = entry.get("pitch_abs")
                        break
            else:
                print()

            if self.og_first_pitch in (UNINIT, NO_DATA):
                print()


        def Noise_zero_out_exit_shift(self):
            self._exit_shift = 0

        def set_committed_data(self):
            first_leaf = next((leaf for leaf in self.leaves if leaf.get_base_pitch() is not NO_DATA), None)
            last_leaf = next((leaf for leaf in reversed(self.leaves) if leaf.get_base_pitch() is not NO_DATA), None)
            if first_leaf is None or last_leaf is None:
                self._exit_shift = 0 #False?
                return
            
            first_bp = first_leaf.get_base_pitch()
            last_bp = last_leaf.get_base_pitch()

            if first_bp is UNINIT or last_bp is UNINIT:
                raise ValueError(f"RiffInstance at idx {self.first_leaf_index} is not committable")


            self._exit_shift = last_bp - first_bp

            return



        # def set_committed_data(self, start_bp: int, exit_shift: int) -> None:
        #     if self._committed:
        #         raise ValueError("Riff data can only be committed once.")

        #     self._committed = True
        #     self._start_bp = start_bp
        #     self._exit_shift = exit_shift








    def extract_pitch_leaves(riff_compressed_seq: List[Union[str, Dict[str, Any]]],) -> List[Union[SegmentLeaf, SegmentCall]]:
        
        flat_segments: List[Union[SegmentLeaf, SegmentCall]] = []
        error_log_lines = []

        active_ids: Set[str] = set()
        leaf_buffer: List[Union[str, Dict[str, Any]]] = []
        note_pitches: List[int] = []
        leaf_start = 0
        idx = 0

        def flush_leaf():
            nonlocal leaf_start
            if leaf_buffer:
                leaf = SegmentLeaf(
                    start=leaf_start,
                    length=len(leaf_buffer),
                    active_ids=set(active_ids),
                    entries=leaf_buffer.copy(),
                    note_pitches=note_pitches.copy(),
                )
                flat_segments.append(leaf)
                leaf_buffer.clear()
                note_pitches.clear()
                leaf_start = idx

        while idx < len(riff_compressed_seq):
            entry = riff_compressed_seq[idx]

            # === Start Marker ===
            if isinstance(entry, str) and entry.startswith("@_") and entry.endswith(":"):
                flush_leaf()
                start_id = entry[2:-1]
                active_ids.add(start_id)
                error_log_lines.append(f"Start Riff ID: {entry} at idx {idx}")
                leaf_buffer.append(entry)
                idx += 1
                continue

            # === End Marker ===
            elif isinstance(entry, str) and entry.startswith("; end @_"):
                end_id = entry[8:]
                if end_id in active_ids:
                    leaf_buffer.append(entry)
                    idx += 1
                    flush_leaf()
                    active_ids.remove(end_id)
                else:
                    error_log_lines.append(f"[WARN] Unexpected end marker: {entry} at idx {idx}")
                    idx += 1
                continue

            # === Riff Call ===
            elif isinstance(entry, dict) and entry.get("type") in ("Riff", "Repeat"):
                flush_leaf()
                flat_segments.append(SegmentCall(start=idx, entry=entry, active_ids=set(active_ids)))
                idx += 1
                continue

            # === Note ===
            elif isinstance(entry, dict) and entry.get("type") == "note":
                pitch_abs = entry.get("pitch_abs")
                if not isinstance(pitch_abs, int):
                    raise TypeError("Note missing pitch_abs at idx {}".format(idx))

                if note_pitches:
                    min_pitch = min(note_pitches)
                    max_pitch = max(note_pitches)
                    pitch_range = max(max_pitch, pitch_abs) - min(min_pitch, pitch_abs) + 1
                    if pitch_range > 15:
                        flush_leaf()

                note_pitches.append(pitch_abs)
                leaf_buffer.append(entry)
                idx += 1
                continue

            # === Default (any other entry) ===
            else:
                leaf_buffer.append(entry)
                idx += 1
                continue

        flush_leaf()

        if active_ids:
            raise ValueError(f"Unclosed riff markers at end of sequence: {active_ids}")

        return flat_segments
















    def build_riff_id_to_RiffInstances_map(segment_leaves: list):
        """
        Constructs a mapping from riff IDs to their associated SegmentLeafs in the composition.
        Skips 'r' (root) leaves and collects all others into per-ID groups.

        Parameters
        ----------
        segment_leaves : list[SegmentLeaf]
            The flat list of all segment leaves in the composition.

        Returns
        -------
        dict[str, RiffInstance]
            A dictionary mapping riff ID strings to RiffInstance objects that record
            their associated leaves, the first occurrence index, and all segment indexes.
        """
        riff_id_to_RiffInstances = {}

        for idx, leaf in enumerate(segment_leaves):
            for riff_id in leaf.active_ids:
                if riff_id == 'r':
                    continue

                if riff_id not in riff_id_to_RiffInstances:
                    first_pitch = NO_DATA


                    if isinstance(leaf, SegmentLeaf):
                        for entry in leaf.entries:
                            if isinstance(entry, dict) and entry.get('type') == 'note':
                                
                                first_pitch = entry.get('pitch_abs')
                                break
                    elif isinstance(leaf, SegmentCall):
                        raise NotImplementedError #Gotta fetch from all notes data.

                    riff_id_to_RiffInstances[riff_id] = RiffInstance(
                        leaves=[],
                        first_leaf_index=idx,
                        og_first_pitch = first_pitch,
                        call_indexes=[],
                    )

                riff_id_to_RiffInstances[riff_id].leaves.append(leaf)
                #riff_id_to_RiffInstances[riff_id].call_indexes.append(idx)


        for riff_id, riff_instance in riff_id_to_RiffInstances.items():
            riff_instance.init_first_pitch()  # You should define this method on the RiffInstance class

        return riff_id_to_RiffInstances




    def assign_leaves_BPs(segment_leaves):

        def recurse_process_leaves(idx):

            def leaf_notes_to_bps(leaf) -> set[int]:
                note_pitches = leaf.note_pitches

                min_bp = max(0, max(note_pitches) - 14)
                max_bp = min(63, min(note_pitches))  # Clamp to range [1, 63]
                if max_bp < min_bp:
                    raise ValueError (f"Bad note range: {note_pitches}")

                valid_bps = set(range(min_bp, max_bp + 1))

                return valid_bps



            def can_commit_riff(riff_id) -> bool:
                riff = riff_id_to_RiffInstances[riff_id]
                
                already_committed = riff.get_exit_shift()
                if already_committed is not UNINIT:
                    return False

                first_leaf = riff.first_leaf_index
                leaf_count = len(riff.leaves)

                last_leaf = first_leaf + leaf_count
                commitable = True
                for i in range(first_leaf, last_leaf):
                    leaf = segment_leaves[i]
                    bp = leaf.get_base_pitch()
                    if bp is UNINIT:
                        commitable = False
                        break

                return commitable



            def commit_leaf_group_idxes(leaf_group_idxes, this_bp):

                for i in leaf_group_idxes:
                    
                    segment_leaf = segment_leaves[i]
                    segment_leaf.set_base_pitch(this_bp)


                for riff_id in riff_id_to_RiffInstances:
                    if can_commit_riff(riff_id): 
                        committed_riff = riff_id_to_RiffInstances[riff_id]
                        committed_riff.set_committed_data() 

                return
            

            def get_riffs_bp(processing_leaf_instance, idx):
                called_id = processing_leaf_instance.called_id
                
                #called_riff_data = riff_id_to_RiffInstances[called_id]

                try:
                    called_riff_data = riff_id_to_RiffInstances[called_id]
                except KeyError:
                    print("Key Error")
                    channel_data
                    return

                exit_shift = called_riff_data.get_exit_shift()
                if exit_shift is UNINIT:

                    nonlocal combined_valid_bps
                    this_bp = h.set_median(combined_valid_bps) 
                    '''
                    To Future Peek:

                    Ideally, this riff call has same base pitch AND no exit shift, it doesn't even need to be commited, as it'll match no matter what. 
                        (detect via: riff_start >= leaf_group_idxes_start)
                                -Really its if exit shift == difference in starting pitches, it'll match for free, but thats even messier.
                    Otherwise:
                        It will always fail. The group gets commited regardless. To properly peek, I'd have to simulate from knowledge I don't have yet. Too much work. 
            
                    '''
                    commit_leaf_group_idxes(leaf_group_idxes, this_bp) 

                    combined_valid_bps = set(range(64))
                    leaf_group_idxes.clear()

                    exit_shift = called_riff_data.get_exit_shift()
                    if exit_shift is UNINIT: #if its STILL not init, Recurse

                        segment_leaves_debug = segment_leaves

                        riff_idx = called_riff_data.first_leaf_index
                        recurse_process_leaves(riff_idx) #Riff Data Can't exist yet. Recurse to generate it. 
                        exit_shift = called_riff_data.get_exit_shift() #On return, it must be here.


                def get_og_data():
                    ogs_bp = None
                    for og_leaf in called_riff_data.leaves:
                        if isinstance(og_leaf, SegmentLeaf):
                            if og_leaf.note_pitches and og_leaf.get_base_pitch() not in (NO_DATA, UNINIT):
                                ogs_bp = og_leaf.get_base_pitch()
                                ogs_first_pitch = called_riff_data.og_first_pitch
                                return ogs_bp, ogs_first_pitch
                        elif isinstance(og_leaf, SegmentCall):

                            ogs_bp = og_leaf.get_base_pitch()
                            ogs_first_pitch = og_leaf.first_pitch #Get the first pitch of the call
                            return ogs_bp, ogs_first_pitch
                    #Fails to find anything.
                    raise ValueError("A call must have a base pitch / notes to reference.")


                # first_leaf = next((leaf for leaf in called_riff_data.leaves if leaf.get_base_pitch() is not NO_DATA), None)
                # if first_leaf is None or first_leaf is UNINIT:
                #     raise ValueError (f"A call must have a base pitch / notes to reference.")
                # ogs_bp = first_leaf.get_base_pitch()
                
                ogs_bp, ogs_first_pitch = get_og_data()

                

                calls_first_pitch = processing_leaf_instance.first_pitch


                calls_bp = ogs_bp + (calls_first_pitch - ogs_first_pitch)

                valid_bps = {calls_bp}



                if exit_shift and leaf_group_idxes:
                    if len(combined_valid_bps) > 16:
                        raise NotImplementedError (f"Trying to save a riff w/ no pitches involved")
                        this_bp = NO_DATA #this shouldn't happen, but may be safe.
                    else:
                        this_bp = min(combined_valid_bps, key=lambda bp: abs(bp - calls_bp))
                    commit_leaf_group_idxes(leaf_group_idxes, this_bp) 
                    leaf_group_idxes.clear()

                return valid_bps


            def update_leaf_group_idxes(combined_valid_bps):
                nonlocal idx 

                if combined_valid_bps & valid_bps:
                    combined_valid_bps &= valid_bps
                    leaf_group_idxes.append(idx)
                    

                else: #commit_leaves
                    #committed_leaf_indexes.discard(idx)
                        #Tell it not to include this one

                    this_bp = min(
                        combined_valid_bps, #minimize distance to next jump.
                        key=lambda bp: min(abs(bp - v) for v in valid_bps)  #CRASH HERE 
                    )
                    commit_leaf_group_idxes(leaf_group_idxes, this_bp)
                
                    leaf_group_idxes.clear()
                    leaf_group_idxes.append(idx) #BUG FIX: may be to just idx -= 1
                        #To tell it to re-load it.

                    combined_valid_bps = valid_bps
                
                return combined_valid_bps

            #=== Recursive Main ===
            nonlocal committed_leaf_indexes

            combined_valid_bps = set(range(64))
            leaf_group_idxes = []

            while idx < len(segment_leaves):


                leaf = segment_leaves[idx]
                commited_bp = leaf.get_base_pitch()

                if commited_bp is not UNINIT:
                    if commited_bp is NO_DATA:
                        idx += 1
                        continue #Skip it.

                    if leaf_group_idxes and commited_bp not in combined_valid_bps:
                        this_bp = min(combined_valid_bps, key=lambda bp: abs(bp - commited_bp))
                        commit_leaf_group_idxes(leaf_group_idxes, this_bp)
                        leaf_group_idxes.clear()

                    combined_valid_bps = {commited_bp} #Things after a committed leaf should try to use that bp.
                    idx += 1
                    continue
                                
                if isinstance(leaf, SegmentLeaf):

                    if not leaf.note_pitches:
                        leaf.set_base_pitch(NO_DATA) #New and Untested.
                        idx += 1
                        continue

                    valid_bps = leaf_notes_to_bps(leaf)

                    combined_valid_bps = update_leaf_group_idxes(combined_valid_bps)


                elif isinstance(leaf, SegmentCall):
                    valid_bps = get_riffs_bp(leaf, idx)

                    commited_bp = leaf.get_base_pitch()
                    if commited_bp is not UNINIT:
                        print(f"Assumed Returned from Recurion")
                        continue

                    id = leaf.called_id
                    call = riff_id_to_RiffInstances[id]
                    exit_shift = call.get_exit_shift()

                    if exit_shift == 0 or exit_shift is UNINIT:
                        combined_valid_bps = update_leaf_group_idxes(combined_valid_bps)  #Standard Update
                    elif exit_shift:
                        if len(valid_bps) != 1:
                            raise ValueError (f"Riff Call has a required bp")
                        else:
                            this_bp = min(valid_bps) #Grab the one valid bp

                        leaf_group_idxes.append(idx)
                        commit_leaf_group_idxes(leaf_group_idxes, this_bp)
                        leaf_group_idxes.clear()

                        this_bp += exit_shift
                        combined_valid_bps = {this_bp}
                        #Just send the leaf group of just this one, base pitch is the valid_bps, singleton.

                    else:
                        raise ValueError (f"leaf group shouldve been commited by get riffs bp")
                    #ERROR: Need to also check the exit shift of the riff. 
                        #If it has a shift, the group commits (always w/o shifting one. Don't have to check it then?)
                        #Then the shifting call gets it own "group" then the set of bps is set to what it will be after it exits. set(this bp += shift)

                else:
                    raise TypeError (f"bad leaf entry: {leaf}")


                committed_leaf_indexes.add(idx)
                idx += 1
            #=== End While ====
            if leaf_group_idxes:
                this_bp = min(combined_valid_bps)
                commit_leaf_group_idxes(leaf_group_idxes, this_bp)
                leaf_group_idxes.clear()

            return


        committed_leaf_indexes = set()
        recurse_process_leaves(idx=0)

        return segment_leaves



    def post_process_BPs():
        def sanity_check_bps():
            for segment in segment_leaves:
                bp = segment.get_base_pitch()
                if not (isinstance(bp, int) or bp is NO_DATA):
                    raise TypeError(
                        f"SegmentLeaf at start={segment.start} has invalid base pitch: {bp} (type={type(bp)})"
                    )

        def ban_shift_at_riff_start():
            for idx, leaf in enumerate(segment_leaves):

                is_call = isinstance(leaf, SegmentCall)

                is_riff_start = (
                    isinstance(leaf, SegmentLeaf) and
                    isinstance(leaf.entries[0], str) and 
                    leaf.entries[0].startswith("@_")
                )

                if is_call or is_riff_start: #Propogate its bp shift back so bps aren't at the start of a riff.
                    for i, next_leaf in enumerate(segment_leaves[idx:]):
                        next_bp = next_leaf.get_base_pitch()
                        if next_bp is not NO_DATA:
                            break

                    if next_bp is NO_DATA:
                        raise NotImplementedError #Ran out of data. probably can safely return.


                    idx += i
                    

                    prev_leaf = segment_leaves[idx-1]
                    prev_bp = prev_leaf.get_base_pitch()
                    if prev_bp is not NO_DATA:
                        print (f"Before Call is Notes")
                        continue
                    
                    prev_idx = idx
                    riffs_exit_modified: list[str] = []
                    while prev_bp is NO_DATA and prev_idx > 0:
                        prev_idx -= 1
                        prev_leaf = segment_leaves[prev_idx] 
                        prev_bp = prev_leaf.get_base_pitch()
                            
                     
                        if isinstance(prev_leaf, SegmentCall):
                            break
                        end_tag = prev_leaf.entries[-1]
                        if isinstance(end_tag,str) and end_tag.startswith("; end @_"): #End tag
                            if prev_bp is not NO_DATA:
                                break 
                            else:
                                ended_id = end_tag.strip("; end @_")
                                riffs_exit_modified.append(ended_id)
                                    #It must calcuale the riff length by the end marker.

                                    #Instead of breaking, It needs to push it back past in, then update the exit shift of the one I shoved it before of. 

                    #What is really the first "safe" point to back it out to?
                    #Hits Notes/A Call, its good.
                    #Reaches Root layer is ALSO good.

                    #Needs to back out of ALL the call labels, no matter how many.

                    prev_idx += 1
                    if prev_idx == idx:
                        continue #Faked out by the Init Header

                    first_NO_DATA_leaf = segment_leaves[prev_idx]
                    if prev_bp is not NO_DATA: #happens if its the first.

                        shift_change = prev_bp - next_bp

                        if riffs_exit_modified and shift_change:
                            for riff_id in riffs_exit_modified:
                            
                                riff_instance = riff_id_to_RiffInstances[riff_id]
                                new_shift = riff_instance.update_exit_shift(shift_change)
                                print (f"[WARN] Riff Exits were Modified: Id: {riff_id} to exit: {new_shift} from {new_shift-shift_change}")

                    first_NO_DATA_leaf.update_base_pitch(next_bp)
                    



        sanity_check_bps()
        ban_shift_at_riff_start()
        return

    """
    
    IDEA:
    When finding the riffs, instead of being greedy by length, first make aliases of small sections found in multiple different patterns. (It'll often improve things to make the patterns smaller)
        -That makes notes even harder to process though. 
    """

    def build_unformatted_byte_seq():
        def leaf_to_bytes(leaf, this_bp, prev_bp):

            def is_shifting_letter_riff(leaf) -> bool:
                

                if not isinstance(leaf, SegmentLeaf):
                    return False
                
                reserved_ids = {"r"}  # Add more if needed
                letter_ids = [k for k in leaf.active_ids if k.isalpha() and k not in reserved_ids]
                if not letter_ids:
                    return False

                if len(letter_ids) > 1:
                    print()
                    raise NotImplementedError("Letter riffs shouldn't collide")

                riff_id = letter_ids[0]
                try:
                    riff_instance = riff_id_to_RiffInstances[riff_id]
                except KeyError:
                    return False

                # Ensure it's the first leaf in the riff
                if leaf is not riff_instance.leaves[0]:
                    return False

                exit_shift = riff_instance.get_exit_shift()
                if not exit_shift:
                    return False

                #  See if this Letter Riff ever uses a Repeat Directive
                for entry in riff_compressed_seq:
                    if (
                        isinstance(entry, dict)
                        and entry.get("type") == "Repeat"
                        and entry.get("count", 0) > 0
                        and entry.get("id") == riff_id
                    ):
                        
                        Does_Repeat = True

                        lettered_leaf = riff_instance.leaves[0]
                        lettered_header = lettered_leaf.entries[0]

                        if (
                            isinstance(lettered_header, str),
                            lettered_header == (f"@_{riff_id}:")
                        ):
                            
                            print(f"Marked Set_Pitch -> this_bp: {this_bp} for riff '{riff_id}' via leaf insertion")
                            return True
                        else:
                            raise ValueError(f"Missing or malformed header before repeat for letter riff '{riff_id}'")

                Does_Repeat = False
                return False


            def handle_pitch_shift():
                diff = this_bp - prev_bp
                if diff == 0:
                    return #No shift needed.

                elif -7 <= diff <= 7:
                    unformatted_byte_seq.append(f"Shift_Pitch {diff}")
                elif not in_riff:
                    unformatted_byte_seq.append(f"Set_Pitch {this_bp-1}")
                else:
                    print (f"[NOTE] Large shift inside riff: {diff}")
                    while not -7 <= diff <= 7:
                        
                        if diff > 0:
                            unformatted_byte_seq.append(f"Shift_Pitch 7")
                            diff -= 7
                        else:
                            unformatted_byte_seq.append(f"Shift_Pitch -7")
                            diff += 7
                    if diff != 0:
                        unformatted_byte_seq.append(f"Shift_Pitch {diff}")

            #===leaf_to_bytes Main===
            nonlocal unformatted_byte_seq

            if prev_bp is UNINIT: #Set Init Header

                if this_bp is NO_DATA:
                    for l in segment_leaves:
                        this_bp = l.get_base_pitch()
                        if this_bp not in (NO_DATA, UNINIT):
                            break
                    if this_bp is NO_DATA: #If still none
                        print (f"No Notes Found.")
                        this_bp = 1 


                # Handle the Init_Header formatting
                entries = leaf.entries
                
                if not entries or not isinstance(entries[0], dict) or entries[0].get("type") != "Init_Header":
                    raise TypeError(f"Expected Init_Header in first entry of first leaf, got: {entries[0]}")

                init_header = entries[0]
                ptr_name = init_header["Ptr_Name"]
                env = init_header["Init_env_pointer"]

                unformatted_byte_seq.append(ptr_name)
                    # Check if Ptr_Name ends with "Noise:"
                if ptr_name.strip().endswith("Noise:"):
                    unformatted_byte_seq.append(";Noise doesn't need base pitch")
                elif ptr_name.strip().endswith("DPCM:"):
                    unformatted_byte_seq.append(f".byte ${this_bp-14:02x}") #DPCM has a different Base Pitch
                    print()
                else:
                    unformatted_byte_seq.append(f".byte ${this_bp-1:02x}")
                unformatted_byte_seq.append(f".byte ${env:02x}")
            
            elif is_shifting_letter_riff(leaf):
                if this_bp is NO_DATA:
                    raise NotImplementedError (f"Need to find the first leaf that has notes to know the riff's start bp.")
                        #Base on Below
                    # first_leaf = next((leaf for leaf in self.leaves if leaf.get_base_pitch() is not NO_DATA), None)


                lettered_pitch = f"Set_Pitch {this_bp - 1}"
                leaf.entries.insert(1, lettered_pitch)

            elif this_bp is not NO_DATA and prev_bp is not NO_DATA:
                handle_pitch_shift()


            #else: #NO_DATA? No pitch shift.


            #Process Entries
            if isinstance(leaf, SegmentCall):
                call_start = leaf.start
                item = riff_compressed_seq[call_start]
                unformatted_byte_seq.append(item)

                if not isinstance(item, (dict,)) or item.get("type") not in {"Riff", "Repeat"}:
                    raise TypeError(f"Expected 'Riff' or 'Repeat' at index {call_start}, got: {item}")
                    #If getting this problem, just append the entry to the object like for leaves.
            
            elif isinstance(leaf, SegmentLeaf):
                for entry in leaf.entries:

                    if isinstance(entry, dict):

                        entry_type = entry.get("type")
                        if entry_type == "Init_Header":
                            continue  # Already handled

                        elif entry_type == "note":
                            pitch_abs = entry["pitch_abs"]
                            length = entry["length"]

                            # High nibble: length
                            if not (0 <= length <= 7):
                                raise ValueError(f"Invalid length in note entry: {length}")
                            high_nibble = length

                            # Low nibble: pitch offset from this_bp
                            pitch_offset = pitch_abs - this_bp + 1
                            if not (1 <= pitch_offset <= 15):
                                raise ValueError(f"Invalid pitch offset (must be 1–15): {pitch_offset} from pitch_abs={pitch_abs} and this_bp={this_bp}")
                            low_nibble = pitch_offset

                            unformatted_byte_seq.append([high_nibble,low_nibble])
                            continue

                    #Copy Normal Entries
                    unformatted_byte_seq.append(entry)

            else:
                raise TypeError("Unknown leaf type")
        #=== Major Main ===
        unformatted_byte_seq = []

        this_bp = UNINIT
        prev_bp = UNINIT
        in_riff = False

        for i, leaf in enumerate(segment_leaves):


            if this_bp is not NO_DATA:
                prev_bp = this_bp
            this_bp = leaf.get_base_pitch()

            if isinstance(leaf, SegmentLeaf):
                ref_ids = leaf.active_ids
                if ref_ids == {'r'}:
                    in_riff = False
                else:
                    in_riff = True


            leaf_to_bytes(leaf, this_bp, prev_bp)


            if prev_bp is UNINIT and this_bp is NO_DATA:
                prev_bp = NO_DATA #Prev bp is only ever UNINIT once

            if isinstance(leaf, SegmentCall):
                called_id = leaf.called_id
                riff_data = riff_id_to_RiffInstances[called_id]

                exit_shift = riff_data.get_exit_shift()
                this_bp += exit_shift

                    
        return unformatted_byte_seq


    #=== Section Main ===

    segment_leaves = extract_pitch_leaves(riff_compressed_seq)


    riff_id_to_RiffInstances = build_riff_id_to_RiffInstances_map(segment_leaves)

    if segment_leaves[0].entries[0].get("Ptr_Name", "").strip().endswith("Noise:"):
        for leaf in segment_leaves:
            leaf.set_base_pitch(1) #Noise hardcodes a shift of 1 (I think. Might be 0)
        for riff_id in riff_id_to_RiffInstances:
            riff_data = riff_id_to_RiffInstances[riff_id]
            riff_data.Noise_zero_out_exit_shift()
    else:
        segment_leaves = assign_leaves_BPs(segment_leaves)
        post_process_BPs()
    
    unformatted_byte_seq = build_unformatted_byte_seq()

    return unformatted_byte_seq #, used_riff_dict




    """
    Plan for Lettered w/ Exit_Shifts:
        -Have the Repeat directive deal with it.  (And I will expand repeat directive to allow 1-4 bytes)
        -ie: If a Repeat A, happens: do shift -2, Call A, repeat x?, size: 3

    """






