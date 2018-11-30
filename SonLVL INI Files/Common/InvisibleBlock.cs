using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Drawing;
using SonicRetro.SonLVL.API;

namespace S3KObjectDefinitions.Common
{
    class InvisibleBlock : ObjectDefinition
    {
        private Sprite img;

        public override void Init(ObjectData data)
        {
            byte[] artfile = ObjectHelper.OpenArtFile("../Objects/Monitor/Nemesis Art/Monitors.bin", CompressionType.Nemesis);
            img = ObjectHelper.MapASMToBmp(artfile, "../Objects/Monitor/Object Data/Map - Monitor.asm", 0, 0);
        }

        public override ReadOnlyCollection<byte> Subtypes
        {
            get { return new ReadOnlyCollection<byte>(new byte[] { 0 }); }
        }

        public override string Name
        {
            get { return "Invisible solid block"; }
        }

        public override string SubtypeName(byte subtype)
        {
            return ((subtype >> 4) + 1) + "x" + ((subtype & 0xF) + 1) + " blocks";
        }

        public override Sprite Image
        {
            get {
				int w = 32;
				int h = 32;
				BitmapBits bmp = new BitmapBits(w, h);
				bmp.FillRectangle(0xE, 0, 0, w - 1, h - 1);
				bmp.DrawRectangle(0xC, 0, 0, w - 1, h - 1);
				for (int i = 1; i < w/2; i++)
					bmp.DrawLine(0xD, i*2, 0, i*2, h - 1);
				//14 17 14
				Sprite spr = new Sprite(bmp, new Point(-(w / 2), -(h / 2)));
				//spr.Offset = new Point(spr.X + obj.X, spr.Y + obj.Y);
				return spr;
			}
        }

        public override Sprite SubtypeImage(byte subtype)
        {
            int w = 32;
            int h = 32;
            BitmapBits bmp = new BitmapBits(w, h);
            bmp.FillRectangle(0xE, 0, 0, w - 1, h - 1);
            bmp.DrawRectangle(0xC, 0, 0, w - 1, h - 1);
			for (int i = 1; i < w/2; i++)
				bmp.DrawLine(0xD, i*2, 0, i*2, h - 1);
			//14 17 14
            Sprite spr = new Sprite(bmp, new Point(-(w / 2), -(h / 2)));
            //spr.Offset = new Point(spr.X + obj.X, spr.Y + obj.Y);
            return spr;
        }

        public override Sprite GetSprite(ObjectEntry obj)
        {
            int w = ((obj.SubType >> 4) + 1) * 16;
            int h = ((obj.SubType & 0xF) + 1) * 16;
            BitmapBits bmp = new BitmapBits(w, h);
            bmp.DrawRectangle(0xC, 0, 0, w - 1, h - 1);
			for (int i = 1; i < w/2; i++)
				bmp.DrawLine(0xD, i*2, 0, i*2, h - 1);
			//14 17 14
            Sprite spr = new Sprite(bmp, new Point(-(w / 2), -(h / 2)));
            spr.Offset = new Point(spr.X + obj.X, spr.Y + obj.Y);
            return spr;
        }

        public override Rectangle GetBounds(ObjectEntry obj, Point camera)
        {
            int w = ((obj.SubType >> 4) + 1) * 16;
            int h = ((obj.SubType & 0xF) + 1) * 16;
            return new Rectangle(obj.X - (w / 2) - camera.X, obj.Y - (h / 2) - camera.Y, w, h);
        }

        public override bool Debug { get { return true; } }
    }
}