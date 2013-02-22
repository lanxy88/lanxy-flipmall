package
{
	/**
	 * 授权类型
	 */
	public class LicenseType
	{
		/**
		 * 试用
		 */
		public static var TRIAL:int = 0;
		/**
		 * 标准，不加载 audio.xml video.xml link.xml buttons.xml
		 */
		public static var STANDARD:int = 1;
		/**
		 * 年度
		 */
		public static var ANNUAL:int = 2;
		/**
		 * 专业
		 */
		public static var PROFESSIONAL = 3;
		/**
		 * 企业
		 */
		public static var ENTERPRISE = 4;
		/**
		 * 全部
		 */
		public static var GLOBAL = 5;
	}
}