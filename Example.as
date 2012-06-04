package 
{
	import flash.display.*;
	import flash.geom.*;
	import flash.text.engine.*;
	import flash.text.*;
	import flash.events.*
	
	public class Example extends Sprite 
	{
		[Embed(source = "ExampleFont.ttf", fontFamily="font1", embedAsCFF="true")]
		static public var fc:Class;
		
		public function Example():void 
		{
			trace(1)
			XTxt.defaults = { fontLookup:FontLookup.EMBEDDED_CFF, fontFamily:"font1", color:0, fontsize:12, em: { color:0x800000 }};
			XTxt.images = imageGenerator
			XML.ignoreWhitespace = false
			
			var mainTxt:XTxt, box:ScrollTxt
			
			var ff:Array = Font.enumerateFonts(true)
			box = new ScrollTxt(							
				{text:
<text>
<style name="c" trackingLeft="-5"/>
<style name="comic" fontFamily="Comic Sans MS"/>
<style name="big" fontSize="16"/>
<p name="top">Here we go</p>
<h>Styles</h>
This is [emphased] text
[red|red text] [strikethrough|strike through] [ fontSize=8|tiny 8pt text]
<h>Nested</h>
<nested textDecoration="underline">underline <big>big [red|red]</big></nested>
<h>Fonts</h>
embedded font [ fontLookup=device|device font]
<noembed fontLookup="device">
default font, [ fontFamily=arial|arial], [ fontFamily=_sans fontStyle=italic|_sans italic], [comic|Comic], [ fontWeight=bold fontFamily=Verdana|Verdana bold]
</noembed>
<h>Images</h>
radius = 5	[:5]
radius = 10	[:10]
radius = 10, thickness = 3	[:10,3]
compact	[: |5][:c|5][:c|5][:c|5]
assorted "circles"	Oo[:3]o[:5]o[:5]o[:3]oO
<h>Tabs</h>
<tabs tabStops="100 200 300 400">Left	100	200	300	400</tabs>
<tabs tabStops="e100 e200 e300 e400">Right	100	200	300	400</tabs>
<tabs tabStops="c100 c200 c300 c400">Center	100	200	300	400</tabs>
<h>Links</h>
<a href="#top">Link to top</a> [ href=#top|link2] Last line
</text>, 
				tabStops:"200 400", red: { color:0xff0000 }, strikethrough: { lineThrough:true }, h: { fontSize:16, color:0x800000, textAlign:"center", paddingTop:"12" }},
				{fancy:true, x:2, y:2, height:300 }
			)			
			
			addChild(box)
			
			addChild(new XTxt({text:"[simple] [:3] label [ href=foo|click]", x:600, y:10, on: {
					click:function(e:Event):void { e.preventDefault(); box.text += "\nbarbarbarbarbarbarbarbarbarbarbarbar\n"}
			}}))
		}				
		
		private function imageGenerator(n:String):DisplayObject {
			var s:Sprite = new Sprite(), si:int;
			var radius:Number, thickness:Number = 1;
			si = n.indexOf(",")
			if (si != -1) {
				radius = Number(n.substr(0, si))
				thickness = Number(n.substr(si + 1))
			} else
				radius = Number(n)
			
			s.graphics.lineStyle(thickness, 0, 1)
			s.graphics.drawCircle(radius, radius, radius)
			return s;
		}
		
	}
}