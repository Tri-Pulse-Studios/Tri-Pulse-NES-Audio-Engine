from typing import Dict, List, Tuple, Optional, Union

class Sentinel:
    def __init__(self, name):
        self.name = name
    def __repr__(self):
        return self.name

UNINIT = Sentinel("UNINIT")
NO_DATA = Sentinel("NO_DATA")


class RiffData:
    def __init__(self, start: int, end: int, id: str):
        self.id = id
        self.start = start
        self.end = end
        
        self.called_indexes = []
        if self.id.isnumeric():
            self.subriffs_dict: Dict[str, RiffData] = {}
        self._next_subriff_idx = 0  # for subriff ids (a, b, c, ...)


    def add_subriff(self, subriff: 'RiffData'):
        self.subriffs_dict[subriff.id] = subriff

    def create_new_subriff(self, start: int, end: int):
        # See if the subriff already exists
        for sub in self.subriffs_dict.values():
            if sub.start == start and sub.end == end:
                print(f"I would have expected all riffs to be found the first go around.")
                result = sub
                break
        else:
            # Create a new one
            letter = chr(ord('a') + self._next_subriff_idx)
            subriff_id = f"{self.id}{letter}"
            self._next_subriff_idx += 1

            result = RiffData(start, end, id=subriff_id)
            self.add_subriff(result)

        return result

    def add_index(self, start_idx: int):
        self.called_indexes.append(start_idx)

    def __repr__(self):
        base = f"RiffData(id={self.id}, start={self.start}, end={self.end}, called_indexes={self.called_indexes}"
        if hasattr(self, 'subriffs_dict'):
            subriffs = list(self.subriffs_dict.keys())
            base += f", subriffs={subriffs}"
        return base + ")"



class ChannelData:
    def __init__(self, channel_name: str, song_data): #SongData):
        self.parent: SongData = song_data
        self._channel_name: Union[str, int] = channel_name

        self.riffs_dict: Dict[str, RiffData] = {}
        self._next_riff_id: int = 0


    def get_channel(self) -> str:
        return self._channel_name

    def get_song_name(self) -> str:
        return self.parent.name

    def create_new_riff(self, start: int, end: int) -> RiffData:
        parent_riff: Optional[RiffData] = None
        for riff in self.riffs_dict.values():
            if riff.start <= start and end <= riff.end:
                if parent_riff is None or riff.start > parent_riff.start:
                    parent_riff = riff

        if parent_riff is not None:
            return parent_riff.create_new_subriff(start, end)
        else:
            riff_id = str(self._next_riff_id)
            self._next_riff_id += 1
            riff = RiffData(start=start, end=end, id=riff_id)
            self.riffs_dict[riff.id] = riff
            return riff

    def get_riffs_at_index(self, idx: int) -> Tuple[List[str], List[str]]:
        starts: List[str] = []
        ends: List[str] = []

        def check_riff(riff: RiffData) -> None:
            if riff.start == idx:
                starts.append(riff.id)
            if riff.end == idx:
                ends.append(riff.id)

            if hasattr(riff, 'subriffs_dict'):
                for sub in riff.subriffs_dict.values():
                    check_riff(sub)

        for riff in self.riffs_dict.values():
            check_riff(riff)

        return starts, ends

    def get_call_at_index(self, idx: int) -> Optional[RiffData]:
        found: Optional[RiffData] = None

        def search(riff: RiffData) -> None:
            nonlocal found
            if idx in riff.called_indexes:
                if found is not None:
                    raise ValueError(
                        f"Index {idx} is listed in multiple called_indexes: {found.id} and {riff.id}"
                    )
                found = riff

            if hasattr(riff, 'subriffs_dict'):
                for sub in riff.subriffs_dict.values():
                    search(sub)

        for riff in self.riffs_dict.values():
            search(riff)

        return found



    def __repr__(self):
        return (f"Channel: {self._channel_name}, (name='{self.parent.name}', "
                f"riffs={list(self.riffs_dict.keys())})")

class SongData:
    def __init__(self, header_data: list[dict], song_name: str ):
        self.name: str = song_name
        self.header_data = header_data
        self.channels: list[ChannelData] = []

    def init_channel(self, channel_name: str) -> ChannelData: #Actually sends self in.
        channel = ChannelData(channel_name=channel_name, song_data=self)
        self.channels.append(channel)
        return channel

    def __repr__(self):
        return (f"SongData(name={self.name!r}, "
                f"header_data={self.header_data!r}, "
                f"channels={self.channels!r})")
#TODO:
"""

SongData is really structured more like ChannelData. SongData would hold things like the Song Name, header data,etc
ChannelData just needs to know its parent object, and if it needs the name for example, the method fetches it from the parent's single source of truth.
"""
