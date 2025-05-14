defmodule StorageImageDownloader.Track do
  @moduledoc false

  alias StorageImageDownloader.Resource

  def get_url(%Resource{try_redirect?: false} = resource), do: resource.url

  def get_url(%Resource{url: url}) do
    try do
      {:ok, response} = Req.get(url, redirect: false)

      case Map.get(response.headers, "location") do
        nil -> nil
        [redirect_url] -> redirect_url
      end
    rescue
      _ -> nil
    end
  end
end
