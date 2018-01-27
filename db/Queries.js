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


    mostPlayedTracks : "select t.*, al.artwork from tracks t inner join albums al on t.album = al.album  and t.artist = al.artist WHERE al.played > 0 ORDER BY played desc LIMIT 100",
    favoriteTracks : "select t.*, al.artwork from tracks t inner join albums al on t.album = al.album and t.artist = al.artist where stars > 0 order by stars desc limit 100",
    recentTracks: "select t.* , al.artwork from tracks t inner join albums al on t.album = al.album and t.artist = al.artist order by strftime(\"%s\", addDate) desc LIMIT 100",
    babedTracks: "select t.* , al.artwork from tracks t inner join albums al on t.album = al.album and t.artist = al.artist where t.babe = 1",

    colorTracks_: "select t.*, al.artwork from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where t.art = \"%1\""

}

var POST = {}

var UPDATE = {}
