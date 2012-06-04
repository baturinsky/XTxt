package  
{	
	import flash.geom.Matrix
	import flash.geom.Point
	import flash.geom.Rectangle
	import flash.display.*
	import flash.events.*
	import flash.utils.*
	
	public class Scrollbox extends Sprite
	{
		public var bar:Sprite, dragger:Sprite, bounds:Rectangle, content:DisplayObject, freeHeight:Number = 0, contentHeight:int
		public static var scrollSpeed:Number = 50, barWidth:int = 12
		public var fancy:BitmapData, fancyb:Bitmap, color:int, fancyOn:Boolean = false
		
		public function Scrollbox(content:DisplayObject, options:Object) 
		{
			bounds = new Rectangle(options.x||0, options.y||0, options.width||(content.width + barWidth), options.height||(content.height))
			this.content = content
			var contentHeight:int = -1
			
			if(options){
				color = options.color || 0;
				contentHeight = options.contentHeight || -1;			
				fancyOn = options.fancy
			}

			addChild(content);
			
			x = bounds.x
			y = bounds.y
			
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, bounds.width + 10, bounds.height);
			
			if(fancyOn){
				fancyb = new Bitmap()
				fancyb.x = bounds.width
				addChild(fancyb)
			}
			
			bar = new Sprite();
			bar.x = bounds.width;			
			addChild(bar);
							
			dragger = new Sprite();
			dragger.graphics.beginFill(0, 0)
			dragger.graphics.drawRect(0, 0, barWidth, 100)
			dragger.x = bounds.width
			addChild(dragger)
							
			//contents.scrollRect = new Rectangle(0, 0, bounds.width, bounds.height);
			
			dragger.addEventListener(MouseEvent.MOUSE_DOWN, moveDrag);
			bar.addEventListener(MouseEvent.MOUSE_DOWN, barClick);
			dragger.addEventListener(Event.ADDED_TO_STAGE, added);
			
			freeHeight = bounds.height - dragger.y;

			if(fancyOn)
				fancy = new BitmapData(barWidth, bounds.height, true);
			
			try {
				(content as Object).scrollTo = scrollTo
			} catch(e:Event){}
				
			updateHeight(contentHeight)
		}

		public function scrollTo(toy:Number):void {
			dragger.y = toy * bounds.height / contentHeight
			var newRect:Rectangle = new Rectangle(bar.x, bar.y, 0, bounds.height - dragger.height)
			update()
		}		
		
		protected function added(m:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, releaseDrag)
			addEventListener(MouseEvent.MOUSE_WHEEL, moveContentWheel)
		}
		
		protected function moveDrag(m:MouseEvent = null):void
		{
			var newRect:Rectangle = new Rectangle(bar.x,bar.y,0,bounds.height - dragger.height)
			dragger.startDrag(false, newRect)
			stage.addEventListener(Event.ENTER_FRAME, update)
		}
		
		protected function barClick(m:MouseEvent):void {
			dragger.y = m.localY - dragger.height / 2
			moveDrag()
			update()
		}		
		
		protected function releaseDrag(m:MouseEvent):void {
			dragger.stopDrag()
			if(stage)
				stage.removeEventListener(Event.ENTER_FRAME, update)
		}
		
		protected function moveContentWheel(m:MouseEvent):void {
			dragger.y = dragger.y - scrollSpeed * m.delta * bounds.height / contentHeight;
			update();
		}
		
		
		public function updateHeight(h:int = -1, stayDown:Boolean = false):void {						
			visible = true
			trace(content.height)
			contentHeight = (h == -1)?content.height:h;			
			if (stayDown){
				var dy:int = dragger.y + dragger.height;
				moveDragger()
				dragger.y = dy - dragger.height;
			}
						
			if (bounds.height < contentHeight) {
				var mx:Matrix = new Matrix()
				mx.scale(barWidth / bounds.width, bounds.height / contentHeight);
				if (fancyOn) {
					fancy.fillRect(fancy.rect,0xffffffff)
					fancy.draw(content, mx)
					fancy.threshold(fancy, fancy.rect, new Point(), ">=", 0x00bbbbbb, 0, 0x00FFFFFF)
					fancyb.bitmapData = fancy
				}
			} else {
				if (fancyOn)
					fancyb.bitmapData = null
			}
			
			update()
		}
		
		public function delayedUpdateHeight(h:int = -1, stayDown:Boolean = false):void {			
			visible = false
			content.scrollRect = null
			setTimeout(updateHeight, 100, h, stayDown)
		}

		public function moveDragger():void
		{									
			dragger.height = bounds.height * bounds.height / contentHeight;			
			dragger.y = Math.max(0, Math.min(bounds.height - dragger.height, dragger.y));
		}
		
		public function update(e:Event = null):void
		{				
			moveDragger()
			drawControls()
		}
		
		public function drawControls(e:Event = null):void
		{
			var dragh:Number = dragger.height;
						
			dragger.visible = bar.visible = (dragh < bounds.height)			
			if(bar.visible){
				bar.graphics.clear();
				bar.graphics.lineStyle(1, color, 0.3)
				bar.graphics.drawRect(0, -1, barWidth, bounds.height);
				bar.graphics.lineStyle(2, color, 1)
				bar.graphics.drawRect(1, dragger.y, barWidth-1, dragger.height);
				bar.graphics.lineStyle(0, color, 0)
				bar.graphics.beginFill(color, 0.1);
				bar.graphics.drawRect(0, -1, barWidth+1, dragger.y);
				bar.graphics.drawRect(0, dragger.y + dragger.height, barWidth+1, bounds.height - (dragger.y + dragger.height));
				content.scrollRect = new Rectangle(0, dragger.y * contentHeight / bounds.height, bounds.width, bounds.height);			
			} else {
				content.scrollRect = null;
			}
		}
	}

}