defmodule StorageImageDownloader.ImageDownloader do
  @moduledoc false

  defprotocol Behaviour do
    @doc "Downloads an image from a given source"
    def download(source, resource)
  end

  defdelegate download(source, resource), to: Behaviour
end
