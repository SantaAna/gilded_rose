defmodule Item do
  @m __MODULE__
  defstruct name: nil, sell_in: nil, quality: nil

  @special_items [
    "Aged Brie",
    "Sulfuras, Hand of Ragnaros",
    "Backstage passes to a TAFKAL80ETC concert"
  ]
  @max_quality 50
  @min_quality 0

  @type t :: %@m{
          name: String.t() | nil,
          sell_in: integer | nil,
          quality: integer | nil
        }

  @doc """
  updates the age of an item.
  """
  @spec age(@m.t()) :: @m.t()
  defp age(%@m{} = item) do
    Map.update!(item, :sell_in, &(&1 - 1))
  end

  @doc """
  Adds quality to an item, the value of an item will
  never exceed the max value in the @max_quality module
  attribute.
  """
  @spec add_quality(integer, integer) :: integer
  defp add_quality(current, addition) do
    min(current + addition, @max_quality)
  end

  @doc """
  Subtracs quality from an item, quality will never
  go below @min_quality attribute.
  """
  @spec subtract_quality(integer, integer) :: integer
  defp subtract_quality(current, decrement) do
    max(current - decrement, @min_quality)
  end
 
  @doc """
  Degrades the quality of a conjured item.
  """
  @spec degrade_conjured_item(@m.t()) :: @m.t()
  defp degrade_conjured_item(item) do
    Map.update!(item, :quality, fn quality ->
      if item.sell_in <= 0 do
        subtract_quality(quality, 4)
      else
        subtract_quality(quality, 2)
      end
    end)
  end

  @doc """
  Degrades the quality of a standard item.
  """
  @spec degrade_normal_item(@m.t()) :: @m.t()
  defp degrade_normal_item(item) do
    Map.update!(item, :quality, fn quality ->
      if item.sell_in <= 0 do
        subtract_quality(quality, 2)
      else
        subtract_quality(quality, 1)
      end
    end)
  end

  @doc """
  # Summary
  Updates the age and quality of either a list of items or a single item. 
  Behavior of the function changes according to the name of the item, see
  sections below

  Throughout we age the item **after** we have updated its quality.

  ## Normal Item      
  For an item that is not in the special item list the item is updated 
  according to the following rules:

  1. If the sell_in value is greater than 0, quality is decremented by 1. 
     if sell_in is less than or equal to zero then it is decremented by 2.
  2. sell_in value is decremented by age() function

  ## Aged Brie
  Aged Brie will increase in value by 1 until its expiration date, after which
  it will increase by 2.

  1. If the sell_in value is greater than 0 quality is incremented by 1. 
  2. If sell_in is less than or equal to zero it is incremented by 2.
  2. sell_in value is decremented by age() function

  ## Backstage Passes
  Backstage passes will increase in value by one until 10 days before expiration.
  At ten days until six days they will be incremented by 2, and between 5 and 1 they
  will be incremented by 3.  Once sell_in reaches zero the quality of the passes  
  is set to zero.

  1. If the sell_in value is greater than 10 quality is incremented by 1. 
  2. If the sell_in value is between 10 and 6 inclusive quality is incremented by 2.
  3. If the sell_in value is betwenn 5 and 1 inclusive quality is incremented by 3.
  4. if the sell_in value is less than or equal to zero quality is set to 0.
  5. sell_in value is decremented by age() function

  ## Sulfuras
  This item will always have value of 80, only its sell_in will be decremented.
  """
  @spec update_quality(list(@m.t()) | @m.t()) :: list(@m.t()) | @m.t()
  def update_quality(item_list) when is_list(item_list) do
    Enum.map(item_list, &update_quality/1)
  end

  def update_quality(%@m{name: name} = item) when name not in @special_items do
    if String.contains?(name, "Conjured") do
      degrade_conjured_item(item)
      |> age()
    else
      degrade_normal_item(item)
      |> age()
    end
  end


  def update_quality(%@m{name: "Aged Brie"} = item) do
    Map.update!(item, :quality, fn quality ->
      if item.sell_in <= 0 do
        add_quality(quality, 2)
      else
        add_quality(quality, 1)
      end
    end)
    |> age()
  end

  def update_quality(%@m{name: "Backstage passes to a TAFKAL80ETC concert"} = item) do
    Map.update!(item, :quality, fn quality ->
      cond do
        item.sell_in in 10..6 -> add_quality(quality, 2)
        item.sell_in in 5..1 -> add_quality(quality, 3)
        item.sell_in > 10 -> add_quality(quality, 1)
        true -> 0
      end
    end)
    |> age()
  end

  def update_quality(%@m{name: "Sulfuras, Hand of Ragnaros"} = item) do
    age(item)
  end
end
