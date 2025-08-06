package com.kavalok.constants {
    import flash.external.ExternalInterface;

    public class ConnectionConfig {
        public static const RTMP_SCHEME:String = "rtmps";
        public static const RTMP_PORT:String = "8443";
        public static const RTMP_APP:String = "kavalok";
        private static const DEFAULT_HOST:String = "127.0.0.1";

        private static function getHostFromJS():String {
            try {
                if (ExternalInterface.available) {
                    var js:String =
                        "function() {" +
                        "  if (typeof window.rtmpHostname === 'string' && window.rtmpHostname.length > 0) {" +
                        "    return window.rtmpHostname;" +
                        "  }" +
                        "  return window.location.hostname;" +
                        "}";

                    var result:String = ExternalInterface.call(js);
                    if (result && result.length > 0) {
                        return result;
                    }
                }
            } catch (e:Error) {}
            return DEFAULT_HOST;
        }

        public static function buildRtmpUrl():String {
            var host:String = getHostFromJS();
            return RTMP_SCHEME + "://" + host + ":" + RTMP_PORT + "/" + RTMP_APP;
        }
    }
}
