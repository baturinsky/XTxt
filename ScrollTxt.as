package  
{
	public class ScrollTxt extends Scrollbox 
	{
		private var txtConf:Object, txt:XTxt
		
		public function ScrollTxt(txtConf:Object, scrollConf:Object)
		{			
			super(txt = new XTxt(txtConf), scrollConf)
			this.txtConf = txtConf
			txt.scrollTo = scrollTo
		}
		
		public function set text(o:Object):void {
			removeChild(txt)
			txtConf.text = o
			addChild(content = txt = new XTxt(txtConf))
			txt.scrollTo = scrollTo
			updateHeight()
		}
		
		public function get text():Object {
			return txt.text
		}
	}

}