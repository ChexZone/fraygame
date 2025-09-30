return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.0",
  name = "tileset",
  class = "",
  tilewidth = 16,
  tileheight = 16,
  spacing = 0,
  margin = 0,
  columns = 128,
  image = "../../assets/images/area/laketown/tileset.png",
  imagewidth = 2048,
  imageheight = 2048,
  objectalignment = "unspecified",
  tilerendersize = "tile",
  fillmode = "stretch",
  tileoffset = {
    x = 0,
    y = 0
  },
  grid = {
    orientation = "orthogonal",
    width = 16,
    height = 16
  },
  properties = {},
  wangsets = {},
  tilecount = 16384,
  tiles = {
    {
      id = 8,
      properties = {
        ["RightCollisionInset"] = 8
      }
    },
    {
      id = 136,
      properties = {
        ["RightCollisionInset"] = 8
      }
    },
    {
      id = 260,
      type = "TestType"
    },
    {
      id = 264,
      properties = {
        ["RightCollisionInset"] = 8
      }
    },
    {
      id = 384,
      animation = {
        {
          tileid = 384,
          duration = 100
        },
        {
          tileid = 385,
          duration = 100
        },
        {
          tileid = 386,
          duration = 100
        },
        {
          tileid = 387,
          duration = 100
        },
        {
          tileid = 388,
          duration = 100
        },
        {
          tileid = 389,
          duration = 100
        },
        {
          tileid = 390,
          duration = 100
        }
      }
    },
    {
      id = 392,
      type = "Tile",
      properties = {
        ["CollisionInset_Bottom"] = 1,
        ["CollisionInset_Left"] = 1,
        ["CollisionInset_Right"] = 1,
        ["CollisionInset_Top"] = 1
      }
    },
    {
      id = 513,
      type = "Tile",
      properties = {
        ["CollisionInset_Bottom"] = 1,
        ["CollisionInset_Left"] = 1,
        ["CollisionInset_Right"] = 1,
        ["CollisionInset_Top"] = 1
      }
    },
    {
      id = 519,
      type = "Tile"
    }
  }
}
