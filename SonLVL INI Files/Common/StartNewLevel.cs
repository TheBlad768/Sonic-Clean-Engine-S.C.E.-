using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Drawing;
using SonicRetro.SonLVL.API;

namespace S3KObjectDefinitions.Common
{
	class StartNewLevel : ObjectDefinition
	{
		private PropertySpec[] properties;
		private ReadOnlyCollection<byte> subtypes;
		private Sprite[] sprite;

		public override string Name
		{
			get { return "Start New Level"; }
		}

		public override bool Debug
		{
			get { return true; }
		}

		public override Sprite Image
		{
			get { return sprite[0]; }
		}

		public override PropertySpec[] CustomProperties
		{
			get { return properties; }
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return subtypes; }
		}

		public override string SubtypeName(byte subtype)
		{
			return null;
		}

		public override Sprite SubtypeImage(byte subtype)
		{
			return sprite[0];
		}

		public override Sprite GetSprite(ObjectEntry obj)
		{
			return sprite[(obj.XFlip ? 1 : 0) | (obj.YFlip ? 2 : 0)];
		}

		public override Sprite GetDebugOverlay(ObjectEntry obj)
		{
			int width = obj.XFlip ? 256 : 32;
			int height = obj.XFlip ? 32 : 256;
			var bitmap = new BitmapBits(width, height);
			bitmap.DrawRectangle(LevelData.ColorWhite, 0, 0, width - 1, height - 1);
			int xOffset = obj.XFlip ? -128 : -16;
			int yOffset = obj.XFlip ? -16 : -128;
			return new Sprite(bitmap, xOffset, yOffset);
		}

		public override Rectangle GetBounds(ObjectEntry obj)
		{
			int xOffset = obj.XFlip ? -128 : -16;
			int yOffset = obj.XFlip ? -16 : -128;
			int width = obj.XFlip ? 256 : 32;
			int height = obj.XFlip ? 32 : 256;
			return new Rectangle(obj.X + xOffset, obj.Y + yOffset, width, height);
		}

		public override void Init(ObjectData data)
		{
			properties = new PropertySpec[2];
			sprite = BuildFlippedSprites(ObjectHelper.UnknownObject);
			subtypes = new ReadOnlyCollection<byte>(new byte[] { 0, 4 });

			properties[0] = new PropertySpec("Next Zone", typeof(int), "Extended",
				"The destination Zone.", null, new Dictionary<string, int>
				{
					{ "Green Hill Zone", 0x00 },
					{ "Marble Zone", 0x01 },
					{ "Spring Yard Zone", 0x02 },
					{ "Labyrinth Zone", 0x03 },
					{ "Star Light Zone", 0x04 },
					{ "Scrap Brain Zone", 0x05 }
				},
				(obj) => obj.SubType >> 2,
				(obj, value) => obj.SubType = (byte)((obj.SubType & 1) | (((int)value << 2) & 0xFE)));

			properties[1] = new PropertySpec("Next Act", typeof(int), "Extended",
				"The destination act.", null,
				(obj) => (obj.SubType & 1) + 1,
				(obj, value) => obj.SubType = (byte)((obj.SubType & 0xFE) | ((int)value == 2 ? 1 : 0)));
		}

		private Sprite[] BuildFlippedSprites(Sprite sprite)
		{
			var flipX = new Sprite(sprite, true, false);
			var flipY = new Sprite(sprite, false, true);
			var flipXY = new Sprite(sprite, true, true);

			return new[] { sprite, flipX, flipY, flipXY };
		}
	}
}
