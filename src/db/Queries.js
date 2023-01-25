var GET = {

    allTracks : "select t.* from tracks t inner join albums al on al.album = t.album and al.artist = t.artist",
    allTracksSimple : "select * from tracks",
    allAlbums : "select * from albums",
    allAlbumsAsc : "select * from albums order by album asc",
    allArtists : "select * from artists",
    allArtistsAsc : "select * from artists order by artist asc",
    albumTracks_ : "select t.* from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where t.album = \"%1\" and t.artist = \"%2\" order by t.track asc",
    artistTracks_ : "select t.* from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where t.artist = \"%1\" order by t.album asc, t.track asc",
    albumTracksSimple_ : "select * from tracks where album = \"%1\" and artist = \"%2\"",
    artistTracksSimple_ : "select * from tracks where artist = \"%1\"",
    tracksWhere_ : "select t.* from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where %1",
    //    sourceTracks_: "select * from tracks where sources_url = \"%1\"",

    mostPlayedTracks : "select t.* from tracks t inner join albums al on t.album = al.album and t.artist = al.artist WHERE t.count >= 3 order by strftime(\"%s\", t.addDate) desc, t.count asc LIMIT 20",

    favoriteTracks : "select t.* from tracks t inner join albums al on t.album = al.album and t.artist = al.artist where rate > 0 order by rate desc limit 100",

    newTracks: "select t.* from (select * from tracks order by releasedate desc, strftime(\"%s\", adddate) desc limit 100) t inner join albums al on t.album = al.album and t.artist = al.artist where t.count <= 4 order by t.title asc limit 20",

    randomTracks: "select t.* from tracks t inner join albums al on t.album = al.album and t.artist = al.artist where t.count <= 4 order by  RANDOM() limit 10",


    oldTracks: "select t.* from (select * from tracks where releasedate > 0 order by releasedate asc limit 100) t inner join albums al on t.album = al.album and t.artist = al.artist order by t.title asc limit 40",

    recentTracks: "select t.* from (select * from tracks order by strftime(\"%s\", lastsync) desc limit 10) t inner join albums al on t.album = al.album and t.artist = al.artist order by t.title asc",
    recentTracks_: "select t.* from (select * from tracks order by strftime(\"%s\", lastsync) desc limit 100) t inner join albums al on t.album = al.album and t.artist = al.artist order by t.title asc",

    recentArtists: "select distinct a.artist from (select * from tracks order by strftime(\"%s\", adddate) desc limit 100) a order by a.artist asc",
    recentAlbums: "select distinct a.album, a.artist from (select * from tracks order by releasedate desc, strftime(\"%s\", adddate) desc limit 100) a order by a.album asc limit 50",

    neverPlayedTracks: "select t.* from tracks t inner join albums al on t.album = al.album and t.artist = al.artist where t.count <= 1 order by RANDOM() limit 20",
    neverPlayedTracks_: "select t.* from (select * from tracks order by strftime(\"%s\", adddate) asc) t inner join albums al on t.album = al.album and t.artist = al.artist where t.count <= 1 order by t.title asc limit 100",

    babedTracks: "#favs",
    playlistTracks_ : "#%1",

    genres: "select distinct genre as tag from tracks",

    tags : "select distinct tag from tags where context = 'tag' limit 1000",
    trackTags : "select distinct tag from tracks_tags where context = 'tag' and tag collate nocase not in (select artist from artists) and tag in (select tag from tracks_tags group by tag having count(url) > 1) order by tag collate nocase limit 1000",
    albumTags_: "select distinct tag from albums_tags where context = 'tag' and album = \"%1\" and artist = \"%2\"",
    artistTags_: "select distinct tag from artists_tags where context = 'tag' and artist = \"%1\"",

}

var INSERT = {
    trackPlaylist_ : "insert into tracks_playlists () ",
}

var UPDATE = {}
