tell application "Spotify"
    if it is running then
        if player state is playing then
            set trackName to name of current track
            set artistName to artist of current track
            return trackName & " - " & artistName
        else
            return "Spotify is paused"
        end if
    else
        return "Spotify is not running"
    end if
end tell
