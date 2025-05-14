defmodule StorageImageDownloader.Helper do
  @moduledoc false

  @dropbox "dropbox.com"
  @google_drive "drive.google.com"

  @spec dropbox?(binary()) :: boolean()
  def dropbox?(url), do: String.contains?(url, @dropbox)

  @spec google_drive?(binary()) :: boolean()
  def google_drive?(url), do: String.contains?(url, @google_drive)

  @spec needs_redirect?(binary()) :: boolean()
  def needs_redirect?(url), do: not dropbox?(url) and not google_drive?(url)
end
