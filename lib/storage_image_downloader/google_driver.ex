defmodule StorageImageDownloader.GoogleDriverDownloader do
  @moduledoc """
  Struct and protocol implementation for Google Drive image downloading.
  """

  alias StorageImageDownloader.Resource

  @type t :: %__MODULE__{
          resource: Resource.t(),
          access_token: String.t()
        }

  defstruct [:resource, :access_token]

  def new(resource, access_token),
    do: struct!(__MODULE__, resource: resource, access_token: access_token)
end

defimpl StorageImageDownloader.ImageDownloader.Behaviour,
  for: StorageImageDownloader.GoogleDriverDownloader do
  alias StorageImageDownloader.GoogleDriverDownloader

  require Logger

  @google_drive "https://drive.google.com/drive/folders"

  def download(%GoogleDriverDownloader{} = downloader, url) do
    cond do
      is_nil(downloader.access_token) ->
        {:error, :no_access_token}

      String.contains?(url, @google_drive) ->
        do_download(url, downloader)

      true ->
        {:error, :google_drive_url_error}
    end
  end

  defp do_download(url, downloader) do
    folder_id = folder_id(url)

    headers = [
      {"Authorization", "Bearer #{downloader.access_token}"},
      {"Accept", "application/json"}
    ]

    query = %{
      q: "'#{folder_id}' in parents",
      fields: "files(id, name, mimeType)"
    }

    response =
      Req.get(
        url: "https://www.googleapis.com/drive/v3/files",
        headers: headers,
        params: query
      )

    case response do
      {:ok, %{status: 403}} ->
        {:error, :invalid_access_token}

      {:ok, %{status: 401}} ->
        {:error, :unauthenticated}

      {:ok, response} ->
        files = response.body["files"]

        if is_nil(files) do
          {:error, :no_files}
        else
          response.body["files"] |> process_files(downloader)
        end

      error ->
        error
    end
  end

  defp process_files(files, downloader) do
    total = Enum.count(files)

    files
    |> Enum.with_index()
    |> Enum.map(fn {file, index} ->
      id = file["id"]
      name = file["name"]

      response =
        Req.get(
          url: "https://www.googleapis.com/drive/v3/files/#{id}",
          headers: [
            {"Authorization", "Bearer #{downloader.access_token}"}
          ],
          params: %{alt: "media"}
        )

      with {:ok, resp} <- response do
        filename = to_string(name)
        save_location = downloader.resource.save_location
        binary = resp.body

        Logger.info("Saving #{index}/#{total}: #{filename}")

        downloader.resource.save_fn.(filename, binary, save_location)
      end
    end)
  end

  defp folder_id(google_drive_url) do
    regex = ~r{/folders/([a-zA-Z0-9_-]+)}
    [_, folder_id] = Regex.run(regex, google_drive_url)

    folder_id
  end
end
