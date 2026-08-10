# See buffer_pool_sim.md for the problem statement.

import time

_disk_store = {i: f"page_{i}_data" for i in range(1000)}
_disk_read_count = 0
_disk_write_count = 0


def disk_read(page_id: int) -> str:
    global _disk_read_count
    _disk_read_count += 1
    time.sleep(0.001)  # simulates disk latency
    return _disk_store.get(page_id, f"page_{page_id}_empty")


def disk_write(page_id: int, contents: str):
    global _disk_write_count
    _disk_write_count += 1
    _disk_store[page_id] = contents


# ================================================================
# YOUR IMPLEMENTATION
# ================================================================
from collections import defaultdict
from dataclasses import dataclass


@dataclass
class Page:
    """Class for tracking an item within the buffer pool"""

    total_pages = 0

    def __init__(
        self,
        pinned: bool = False,
        contents: str = "",
        in_pool: bool = True,
    ):
        self.page_id = Page.total_pages
        Page.total_pages += 1
        self.pinned = pinned
        self.contents = contents
        self.in_pool = in_pool


class LinkedList:
    def __init__(self):
        self.head = Node(Page())
        self.tail = Node(Page())

    def add_node(self, page: Page):
        if not self.head:
            self.head = Node(page)
            self.tail = self.head
        else:
            tmp = self.head
            self.head = Node(page)
            self.head.next = tmp

    def remove_node(self):
        # Only remove if not pinned
        while self.tail.next:
            if self.tail and not self.tail.data.pinned:
                del self.tail


class Node:
    def __init__(self, page: Page):
        self.data = page
        self.next = Node(Page())


class BufferPool:
    def __init__(self, capacity: int):
        # Once a page reaches the pool, it goes
        # from a simple page_id/string to a typed
        # Page object
        self.dict = {}
        self.ll = LinkedList()
        self.capacity = capacity

    def fetch_page(self, page_id: int) -> str:
        if page_id not in self.dict:
            cnts = disk_read(page_id)
            self.dict[page_id] = Page(contents=cnts)
            if len(self.dict) > self.capacity:
                self.ll.remove_node()
            self.ll.add_node(page_id)
            # Returning the in-memory "pointer"
            # back to the caller
            return self.dict[page_id].contents
        else:
            if len(self.dict) > self.capacity:
                self.ll.remove_node()
            self.ll.add_node(page_id)
            return self.dict[page_id].contents

    def pin(self, page_id: int):
        self.dict[page_id].pinned = True

    def unpin(self, page_id: int):
        self.dict[page_id].pinned = False

    # Part 2
    def mark_dirty(self, page_id: int):
        pass

    def flush_page(self, page_id: int):
        pass

    def eviction_cost(self, page_id: int) -> str:
        pass

    # Part 3
    def prefetch(self, page_ids: list) -> list:
        pass

    def stats(self) -> dict:
        pass


# ================================================================
# TESTS — run after each part
# ================================================================


def test_part1():
    pool = BufferPool(3)
    assert pool.fetch_page(1) == "page_1_data"
    assert pool.fetch_page(2) == "page_2_data"
    assert pool.fetch_page(3) == "page_3_data"
    pool.pin(1)
    result = pool.fetch_page(4)  # pool full, pin(1) safe, evict LRU of {2,3}
    assert result == "page_4_data"
    pool.unpin(1)
    print("Part 1 passed")


def test_part2():
    pool = BufferPool(2)
    pool.fetch_page(10)
    pool.fetch_page(20)
    pool.mark_dirty(10)
    assert pool.eviction_cost(10) == "flush"
    assert pool.eviction_cost(20) == "free"
    pool.fetch_page(30)  # evicts dirty page 10 — should trigger disk_write
    print("Part 2 passed")


def test_part3():
    pool = BufferPool(3)
    pool.fetch_page(1)
    pool.pin(1)
    pool.pin(2) if False else None  # only 1 pinned
    skipped = pool.prefetch(
        [2, 3, 4, 5]
    )  # loads 2,3,4 — pool full after 3 loads, 5 skipped? depends on pin state
    s = pool.stats()
    assert "in_pool" in s
    assert "disk_reads" in s
    print("Part 3 passed")
    print("Stats:", s)


if __name__ == "__main__":
    test_part1()
    test_part2()
    test_part3()
