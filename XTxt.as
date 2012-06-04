package  
{
    import mx.utils.*;
    import flash.display.*;
    import flash.text.engine.*;
	
	import flashx.textLayout.elements.*;
	import flashx.textLayout.events.*;
	import flashx.textLayout.container.*;
	import flashx.textLayout.edit.*;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.conversion.*;
	import flashx.textLayout.compose.*;
	
	public class XTxt extends Sprite 
	{		
		public static var defaults:Object, images:Function = null;
		public var options:Object, style:Object, namedLeafs:Object, anchor:Object/*, stripSomeWhitespaces:Boolean = false*/;
		public var textFlow:TextFlow, cc:ContainerController, tlformat:TextLayoutFormat, rootPara:ParagraphElement, listeners:Object, scrollTo:Function;
		
		private var icoReg:RegExp = /(\[.+?\])/g
				
		public function textToElements(t:String):Array {
			t = t.replace(/^\r?\n\t*/, "")
			t = t.replace(/\r?\n$/, "")			
					
			if (t.length == 0)
				return null
				
			var elements:Array = []
				
			var a:Array = t.split(icoReg)
			
			for each(var s:String in a) {
				if (s == null)
					continue
					
				var c0:String = s.charAt(0)
				var styleName:String
				var leftPart:String
				var args:Object = []
				
				var isImg:Boolean = false, isLink:Boolean = false
				styleName = null
				if (c0 == "[") {
					var c1:String = s.charAt(1)
					isImg = (c1 == ":")
					s = s.substring(isImg?2:1, s.length-1)
					var i:int = s.indexOf("|");
					if (i != -1){
						leftPart = s.substr(0, i)
						var hs:Array = leftPart.split(/[ =:]/)
						styleName = hs[0]
						args = []
						for (var j:int = 1; j < hs.length; j += 2)
							args[hs[j]] = hs[j+1]
						s = s.substr(i + 1)
					}
					isLink = args["href"] != undefined
					
					if(!styleName || styleName=="")
						styleName = isLink?"a":isImg?"img":args.length==1?"em":"default"
				} else {
					styleName = "default"
				}
				
				var element:FlowElement
				
				if (isImg) {
					if(images != null){
						element = new InlineGraphicElement()
						var b:DisplayObject = images(s)
						if(b)
							(element as InlineGraphicElement).source = b
					}
				} else {
					var se:SpanElement = new SpanElement()					
					se.text = s
					if (isLink) {
						var link:LinkElement = linkElement(args["href"])
						link.addChild(se)
						element = link
					} else {
						element = se
					}
				}
				
				if(element){
					setStyle(element, styleName, args)
					elements.push(element)
				}
				args = null
			}
			return elements
		}
		
		public function setStyle(p:Object, name:String, extra:Object = null):void {
			
			var n:String, how:Object
			
			if(name && name!="text"){
				how = options[name]
				if(how)
					for (n in how)
						p[n] = how[n]
						
				if(style){
					how = style[name]
					if(how)
						for (n in how)
							p[n] = how[n]
				}
			}
					
			if(extra) {
				if(extra is XML){
					var xml:XML = extra as XML
					for each(var a:XML in xml.@* )
						setProp(p, a.name(), xml.attribute(a.name()))
				} else {
					for (n in extra)
						setProp(p, n, extra[n])
				}
			}
		}
		
		public function setProp(p:Object, n:String, v:String):void {
			if (n in p || !(p is FlowElement)) {
				var num:Number = Number(v)
				if (!isNaN(num))
					p[n] = num
				else
					p[n] = v
			}			
		}

		public function linkElement(href:String):LinkElement {
			var link:LinkElement = new LinkElement()
			if (href.charAt(0) == "#")
				link.addEventListener("click", anchorListener)
			else
				if (listeners) {
					for (var ln:String in listeners)
						link.addEventListener(ln, listeners[ln])
				}			
			return link
		}
		
		public function xmlToElement(xml:XML):FlowGroupElement {			
				
			var n:String, p:FlowGroupElement;
			
			if (xml.name() == "style") {
				style ||= { }
				style[xml.@name] ||= { }
				setStyle(style[xml.@name], null, xml)
				delete style[xml.@name].name
				return null
			}
			
			var elements:Array = []
			
			for each(var c:XML in xml.children()) {
				if (c.nodeKind() == "text")
					elements = elements.concat(textToElements(c.toString()))
				else
					elements.push(xmlToElement(c))
			}

			//divs can only have divs and paragraphs, links can only have spans and images
			if (xml.hasOwnProperty("@href")){
				p = linkElement(xml.@href)
			} else{
				for each(var e:FlowElement in elements) {
					if (e is ParagraphElement || e is DivElement){
						p = new DivElement()
						break
					}
				}				
				p ||= new ParagraphElement()
			}			
					
			try{
				setStyle(p, xml.name(), xml)
			} catch (e:Object) {
				p = divWith(p)
				setStyle(p, xml.name(), xml)
			}
						
			if (xml.hasOwnProperty("@name")) {
				namedLeafs ||= {}
				namedLeafs[xml.@name] = p
			}
			
			var lp:ParagraphElement
			
			if (p is DivElement) {
				lp = null
				for each(e in elements){
					if (e is LinkElement || e is InlineGraphicElement || e is SpanElement) {	
						if(!lp)
							lp = new ParagraphElement()
						lp.addChild(e)
					} else {
						p.addChild(lp)
						p.addChild(e)
						lp = null
					}
				}
				if (lp)
					p.addChild(lp)
			} else {
				for each(e in elements)
					p.addChild(e)
			}
			
			return p
		}
						
		public function paragraphWith(e:FlowElement):ParagraphElement {
			if (e is ParagraphElement)
				return e as ParagraphElement;
			var ne:ParagraphElement = new ParagraphElement()
			ne.addChild(e)
			return ne
		}

		public function divWith(e:FlowElement):DivElement {
			if (e is DivElement)
				return e as DivElement
			var ne:DivElement = new DivElement()
			ne.addChild(paragraphWith(e))
			return ne
		}
		
		public function XTxt(param:Object) 		
		{	
			var content:Object
			if (param is String || param is XML) {
				content = param
				options = {}
			} else {
				content = param.text
				options = param
			}
						
			listeners = options.on
			
			if (defaults)
				for (var dn:String in defaults)
					if (!(dn in options))
						options[dn] = defaults[dn]
			
			cc = new ContainerController(this, options.w || 100, options.h || 20)
			
			var config:Configuration = new Configuration()
			tlformat = new TextLayoutFormat()
						
			for (var os:String in options) {
				if (os in tlformat){
					tlformat[os] = options[os]
				} else if (os in this && os != "text") {
					this[os] = options[os]
				}
			}
			
			config.textFlowInitialFormat = tlformat;
						
			textFlow = new TextFlow(config);
			textFlow.whiteSpaceCollapse = "preserve"
            textFlow.flowComposer.addController(cc)
			
			if(content)
				text = content
		}
		
		public function anchorListener(evt:FlowElementMouseEvent):void {
			evt.preventDefault()
			var href:String = (evt.flowElement as LinkElement).href.substring(1)
			scrollTo(anchor[href])			
		}
		
		protected var plainText:String = ""
		
		public function set text(txt:Object):void {	
			if (txt is XML) {
				setRoot(xmlToElement(txt as XML))
				style = null				
			} else {
				txt = txt.toString()
				if (plainText == txt)
					return
				plainText = txt.toString()
				var p:ParagraphElement = new ParagraphElement()
				for each(var e:FlowElement in textToElements(plainText))
					p.addChild(e)
				setRoot(p)
			}
		}
		
		public function get text():Object {	
			return plainText
		}
				
		public function setRoot(p:FlowElement):void {
			while(textFlow.numChildren > 0)
				textFlow.removeChildAt(0)
			
            textFlow.addChild(p)
			
			if (!options.cheight) {
				textFlow.flowComposer.updateAllControllers()
				cc.setCompositionSize(options.w, contentHeight)
			}

            textFlow.flowComposer.updateAllControllers()
			
			if (namedLeafs) {
				anchor = {}
				for (var n:String in namedLeafs) {
					var fe:FlowElement = namedLeafs[n]
					var start:int = fe.getAbsoluteStart()
					var line:TextFlowLine = textFlow.flowComposer.findLineAtPosition(start);
					if(line)
						anchor[n] = line.y
				}
			}
				
		}
		
		public function get contentHeight():Number {
			return cc.getContentBounds().height*1.01 + 10; //As docs say, getContentBounds is not accurate
		}
		
		public function get contentWidth():Number {
			return cc.getContentBounds().width
		}
	}	
}