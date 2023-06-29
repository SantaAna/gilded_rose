defmodule GildedRoseTest do
  import GildedRose
  use ExUnit.Case

  test "begin the journey of refactoring" do
    items = [%Item{name: "foo", sell_in: 0, quality: 0}]
    GildedRose.update_quality(items)
    %{name: firstItemName} = List.first(items)
    assert "foo" == firstItemName
  end

  test "item sell_in in decreases by 1 for all item types" do
    updated_items =
      update_quality([
        %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 9, quality: 1},
        %Item{name: "junk", sell_in: 9, quality: 2},
        %Item{name: "Aged Brie", sell_in: 9, quality: 2},
        %Item{name: "Sulfuras", sell_in: 9, quality: 2}
      ])

    assert Enum.all?(updated_items, &(&1.sell_in == 8))
  end

  describe "testing for conjured item" do
    test "conjured item quality decreases by 2 before expiration" do
      conjured_items =
        update_quality([
          %Item{name: "Conjured junk", sell_in: 9, quality: 4},
          %Item{name: "Conjured junk", sell_in: 1, quality: 4}
        ])

      assert Enum.all?(conjured_items, &(&1.quality == 2))
    end

    test "conjured items quality decreases by 4 after expiration" do
      conjured_items =
        update_quality([
          %Item{name: "Conjured junk", sell_in: 0, quality: 4},
          %Item{name: "Conjured junk", sell_in: -2, quality: 4}
        ])

      assert Enum.all?(conjured_items, &(&1.quality == 0))
    end

    test "conjured items quality does not decrease below 0" do
      conjured_items =
        update_quality([
          %Item{name: "Conjured junk", sell_in: 0, quality: 2},
          %Item{name: "Conjured junk", sell_in: -2, quality: 2},
          %Item{name: "Conjured junk", sell_in: 1, quality: 1}
        ])

      assert Enum.all?(conjured_items, &(&1.quality == 0))
    end
  end

  describe "testing behavior for normal items" do
    test "quality decreases by 1 for normal items" do
      updated_items =
        update_quality([
          %Item{name: "junk", sell_in: 9, quality: 2}
        ])

      assert Enum.at(updated_items, 0).quality == 1
    end

    test "quality does not go below 0 for normal items" do
      updated_items =
        update_quality([
          %Item{name: "junk", sell_in: 9, quality: 0},
          %Item{name: "junk", sell_in: 0, quality: 0},
          %Item{name: "junk", sell_in: -1, quality: 0}
        ])

      assert Enum.all?(updated_items, &(&1.quality == 0))
    end

    test "quality of normal item degrades by 2 when sell_in is 0" do
      updated_items =
        update_quality([
          %Item{name: "junk", sell_in: 0, quality: 2},
          %Item{name: "junk", sell_in: -1, quality: 2}
        ])

      assert Enum.all?(updated_items, &(&1.quality == 0))
    end
  end

  describe "testing behavior for 'Aged Brie'" do
    test "'Aged Brie' increases in value until sell by date has passed" do
      bries =
        update_quality([
          %Item{name: "Aged Brie", sell_in: 10, quality: 2},
          %Item{name: "Aged Brie", sell_in: 1, quality: 2}
        ])

      assert Enum.all?(bries, &(&1.quality == 3))
    end

    test "'Aged Brie' value increases by 2 after its sell by date" do
      bries =
        update_quality([
          %Item{name: "Aged Brie", sell_in: 0, quality: 2},
          %Item{name: "Aged Brie", sell_in: -1, quality: 2}
        ])

      assert Enum.all?(bries, &(&1.quality == 4))
    end

    test "'Aged Brie' value never exceeds 50" do
      bries =
        update_quality([
          %Item{name: "Aged Brie", sell_in: 0, quality: 50},
          %Item{name: "Aged Brie", sell_in: -1, quality: 50},
          %Item{name: "Aged Brie", sell_in: 10, quality: 50}
        ])

      assert Enum.all?(bries, &(&1.quality == 50))
    end
  end

  describe "testing behavior for 'Sulfuras'" do
    test "'Sulfuras, Hand of Ragnaros' never decreases in value" do
      sulfs =
        update_quality([
          %Item{name: "Sulfuras, Hand of Ragnaros", sell_in: 0, quality: 80},
          %Item{name: "Sulfuras, Hand of Ragnaros", sell_in: -1, quality: 80},
          %Item{name: "Sulfuras, Hand of Ragnaros", sell_in: 10, quality: 80}
        ])

      assert Enum.all?(sulfs, &(&1.quality == 80))
    end
  end

  describe "testing behavior for 'Backstage passes to a TAFKAL80ETC concert'" do
    test "'Backstage passes to a TAFKAL80ETC concert' increases in value by 1 for more than 10 days out" do
      passes =
        update_quality([
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 20, quality: 10},
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 12, quality: 10},
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 11, quality: 10}
        ])

      assert Enum.all?(passes, &(&1.quality == 11))
    end

    test "'Backstage passes to a TAFKAL80ETC concert' increases in value by 2 if between 10 and 5 days out" do
      passes =
        update_quality([
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 10, quality: 10},
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 6, quality: 10},
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 8, quality: 10}
        ])

      assert Enum.all?(passes, &(&1.quality == 12))
    end

    test "'Backstage passes to a TAFKAL80ETC concert' increases in value by 3 if between 5 and 0 days out" do
      passes =
        update_quality([
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 5, quality: 10},
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 3, quality: 10},
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 1, quality: 10}
        ])

      assert Enum.all?(passes, &(&1.quality == 13))
    end

    test "'Backstage passes to a TAFKAL80ETC concert' quality will never exceed 50" do
      passes =
        update_quality([
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 5, quality: 50},
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 20, quality: 50},
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 1, quality: 50}
        ])

      assert Enum.all?(passes, &(&1.quality == 50))
    end

    test "'Backstage passes to a TAFKAL80ETC concert' quality goes to 0 at expiration" do
      passes =
        update_quality([
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: -13, quality: 10},
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: -12, quality: 20},
          %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 0, quality: 15}
        ])

      assert Enum.all?(passes, &(&1.quality == 0))
    end
  end
end
