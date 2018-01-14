var Query = {

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

}
