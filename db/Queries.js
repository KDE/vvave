var GET = {

    allTracks : "select t.*, al.artwork from tracks t inner join albums al on al.album = t.album and al.artist = t.artist",
    allTracksSimple : "select * from tracks",
    allAlbums : "select * from albums",
    allAlbumsAsc : "select * from albums order by album asc",
    allArtists : "select * from artists",
    allArtistsAsc : "select * from artists order by artist asc",
    albumTracks_ : "select t.*, al.artwork from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where t.album = \"%1\" and t.artist = \"%2\" order by t.track asc",
    artistTracks_ : "select t.*, al.artwork from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where t.artist = \"%1\" order by t.album asc, t.track asc",
    albumTracksSimple_ : "select * from tracks where album = \"%1\" and artist = \"%2\"",
    artistTracksSimple_ : "select * from tracks where artist = \"%1\"",
    tracksWhere_ : "select t.*, al.artwork from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where %1",
//    sourceTracks_: "select * from tracks where sources_url = \"%1\"",

    mostPlayedTracks : "select t.*, al.artwork from tracks t inner join albums al on t.album = al.album and t.artist = al.artist WHERE t.count > 0 ORDER BY count desc LIMIT 100",
    favoriteTracks : "select t.*, al.artwork from tracks t inner join albums al on t.album = al.album and t.artist = al.artist where rate > 0 order by rate desc limit 100",
    recentTracks: "select t.* , al.artwork from tracks t inner join albums al on t.album = al.album and t.artist = al.artist order by strftime(\"%s\", t.addDate) desc LIMIT 100",
    babedTracks: "#favs",
    playlistTracks_ : "select t.* , al.artwork from tracks t inner join albums al on t.album = al.album and t.artist = al.artist inner join tracks_playlists pl on pl.url = t.url where pl.playlist = \"%1\" order by strftime(\"%s\", pl.addDate) desc",
    playlists: "select * from playlists order by strftime(\"%s\", addDate) desc",

    genres: "select distinct genre as tag from tracks",

    tags : "select distinct tag from tags where context = 'tag' limit 1000",
    trackTags : "select distinct tag from tracks_tags where context = 'tag' and tag collate nocase not in (select artist from artists) and tag in (select tag from tracks_tags group by tag having count(url) > 1) order by tag collate nocase limit 1000",
    albumTags_: "select distinct tag from albums_tags where context = 'tag' and album = \"%1\" and artist = \"%2\"",
    artistTags_: "select distinct tag from artists_tags where context = 'tag' and artist = \"%1\"",


    colorTracks_: "select t.*, al.artwork from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where t.color = \"%1\""

}

var INSERT = {
    trackPlaylist_ : "insert into tracks_playlists () ",
}

var UPDATE = {}
