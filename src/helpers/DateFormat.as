package helpers
{
	public class DateFormat
	{
		public static const DIA:int = 86400000;
		
		private static var token:RegExp = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
			timezone:RegExp = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
			timezoneClip:RegExp = /[^-+\dA-Z]/g;
		
		public static var masks:Object = {
			"default": "dd/mm/yy hh:MM:ss TT",
			shortDate: "m/d/yy",
			mediumDate: "mmm d, yyyy",
			longDate: "mmmm d, yyyy",
			fullDate: "dddd, mmmm d, yyyy",
			shortTime: "h:MM TT",
			mediumTime: "h:MM:ss TT",
			longTime: "h:MM:ss TT Z",
			isoDate: "yyyy-mm-dd",
			isoTime: "HH:MM:ss",
			isoDateTime: "yyyy-mm-dd'T'HH:MM:ss",
			isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
		};
		public static var i18n:Object = {
			dayNames: [
				"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
				"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
			],
			monthNames: [
				"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
				"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
			]
		};
		
		public function DateFormat()
		{
			
		}
		
		private static function pad (val:*,len:int=2):String {
			val = String(val);
			//len = len || 2;
			while (val.length < len) val = "0" + val;
			return val;
		}
		
		public static function format (date:*,mask:String="yyyy-mm-dd",utc:Boolean=false):String {
									
			// Passing date through Date applies Date.parse, if necessary
			date = date ? new Date(date) : new Date;
			if (isNaN(date)) throw SyntaxError("invalid date");
			
			mask = String(masks[mask] || mask || masks["default"]);
			
			// Allow setting the utc argument via the mask
			if (mask.slice(0, 4) == "UTC:") {
				mask = mask.slice(4);
				utc = true;
			}
			var _:String  = utc ? "getUTC" : "get",
				d:Number = date[_ + "Date"](),
				D:Number = date[_ + "Day"](),
				m:Number = date[_ + "Month"](),
				y:Number = date[_ + "FullYear"](),
				H:Number = date[_ + "Hours"](),
				M:Number = date[_ + "Minutes"](),
				s:Number = date[_ + "Seconds"](),
				L:Number = date[_ + "Milliseconds"](),
				o:Number = utc ? 0 : date.getTimezoneOffset(),
				flags:Object = {
					d: d,
					dd: pad(d),
					ddd: i18n.dayNames[D],
						dddd: i18n.dayNames[D + 7],
						m: m + 1,
						mm: pad(m + 1),
						mmm: i18n.monthNames[m],
						mmmm: i18n.monthNames[m + 12],
						yy: String(y).slice(2),
						yyyy: y,
						h: H % 12 || 12,
						hh: pad(H % 12 || 12),
						H: H,
						HH: pad(H),
						M: M,
						MM: pad(M),
						s: s,
						ss: pad(s),
						l: pad(L, 3),
						L: pad(L > 99 ? Math.round(L / 10) : L),
						t: H < 12 ? "a" : "p",
						tt: H < 12 ? "am" : "pm",
						T: H < 12 ? "A" : "P",
						TT: H < 12 ? "AM" : "PM",
						Z: utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
						o: (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
						S: ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : Number(d % 100 - d % 10 != 10) * d % 10]
				};
			
			return mask.replace(token, function (a:*,b:*,c:*,d:*):String {
				return a in flags ? flags[a] : a.slice(1, a.length - 1);
			});
		}
		
		private static var a:Array=[];
		private static var d:Date;
		public static function toDate (date:String,plus:Number=0):Date {
			a = date.split("-");
			d = new Date(a[0],int(a[1])-1,a[2]);
			d.time += plus;
			return d;
		}
		
		public static function msToString(ms:int):String {
			var x:int; a.length=0;
			x = int(ms / 1000);
			a.push(x % 60);
			a.push(x % 60 + "s");
			x = int(x/60);
			a.push(x % 60 + "m");
			x = int(x/60);
			a.push(x % 24 + "h");
			/*x = int(x/24);
			a.push(x + "d");*/
			return a.reverse().join(":");
		}
	}
}