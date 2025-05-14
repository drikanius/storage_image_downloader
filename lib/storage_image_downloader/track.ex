defmodule StorageImageDownloader.Track do
  @moduledoc false

  alias StorageImageDownloader.Resource

  def get_url(%Resource{try_redirect?: false} = resource), do: resource.url

  def get_url(%Resource{url: url} = _) do
    {:ok, response} = Req.get(url, redirect: false)

    [redirect_url] = response.headers["location"]

    redirect_url
  end
end
