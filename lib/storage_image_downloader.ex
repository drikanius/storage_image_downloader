defmodule StorageImageDownloader do
  @moduledoc """
  Protocol for downloading images from various backends.
  """

  # defprotocol Behaviour do
  #   @doc "Downloads an image from a given source"
  #   def download(source, resource)
  # end

  # defdelegate download(source, resource), to: Behaviour

  alias StorageImageDownloader.{
    ImageDownloader,
    DropboxDownloader,
    GoogleDriverDownloader,
    Track,
    Helper
  }

  def download(resource, validate_folder? \\ false) do
    url = Track.get_url(resource)
    save_location = resource.save_location

    with :ok <- validate_save_location(save_location, validate_folder?) do
      choose_behavior(resource, url)
    end
  end

  defp choose_behavior(resource, url) do
    cond do
      Helper.dropbox?(url) ->
        ImageDownloader.download(DropboxDownloader.new(resource), url)

      Helper.google_drive?(url) ->
        ImageDownloader.download(GoogleDriverDownloader.new(resource, resource.access_token), url)

      true ->
        {:error, :behaviour_not_implemented}
    end
  end

  defp validate_save_location(folder_path, true) do
    if File.dir?(folder_path), do: :ok, else: {:error, :invalid_folder_path}
  end

  defp validate_save_location(_, _), do: :ok
end
