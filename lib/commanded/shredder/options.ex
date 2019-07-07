defmodule Commanded.Shredder.Options do
  @moduledoc false

  def validate_options([]), do: {:error, "no_options_passed"}
  def validate_options(nil), do: {:error, "nil_options"}

  def validate_options(opts) do
    key_field = get_key_field(opts)
    fields = get_fields(opts)

    case {key_field, Keyword.keyword?(fields)} do
      {key_field, true} when is_tuple(key_field) ->
        :ok

      {_, false} ->
        {:error, "invalid_fields"}

      _ ->
        {:error, "invalid_key_field"}
    end
  end

  def validate_fields(event, opts \\ []) do
    fields = get_fields(opts)
    struct_fields = Map.keys(event)

    if Keyword.keyword?(fields) do
      (Keyword.keys(fields) -- struct_fields)
      |> Enum.empty?()
      |> if(do: :ok, else: {:error, "event_fields_missing"})
    else
      {:error, "invalid_fields"}
    end
  end

  def validate_key_field(event, opts) do
    case get_key_field(opts) do
      nil ->
        {:error, "invalid_key_field"}

      {key_field, _} ->
        if Map.has_key?(event, key_field) and Map.get(event, key_field) |> is_binary() do
          :ok
        else
          {:error, "event_missing_key_field"}
        end
    end
  end

  @spec get_key_field(opts :: Keyword.t()) ::
          {key_field :: atom, prefix :: String.t()}
          | nil
  def get_key_field(opts) do
    case Keyword.get(opts, :key_field) do
      [key_field, {:prefix, prefix}] when is_atom(key_field) and is_binary(prefix) ->
        {key_field, prefix}

      key_field when is_atom(key_field) ->
        {key_field, ""}

      _ ->
        nil
    end
  end

  @spec get_fields(opts :: Keyword.t()) :: list | nil
  def get_fields(opts),
    do:
      Keyword.get(opts, :fields)
      |> normalize_fields()

  defp normalize_fields(fields)
       when is_list(fields),
       do: Enum.map(fields, &normalize_field/1)

  defp normalize_fields(_fields),
    do: nil

  defp normalize_field(field)
       when is_atom(field),
       do: {field, nil}

  defp normalize_field({field, default} = pair)
       when is_atom(field) and is_binary(default),
       do: pair

  defp normalize_field(_field),
    do: nil
end
