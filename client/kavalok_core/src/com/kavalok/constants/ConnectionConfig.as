package com.kavalok.constants {
import flash.external.ExternalInterface;

public class ConnectionConfig {
    public static const RTMP_PORT:String = "8935";
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

    private static function isHttpsPage():Boolean {
        try {
            if (ExternalInterface.available) {
                var js:String =
                    "function() {" +
                    "  return window.location.protocol === 'https:';" +
                    "}";
                return ExternalInterface.call(js) === true;
            }
        } catch (e:Error) {}
        return false;
    }

    public static function buildRtmpUrl():String {
        var host:String = getHostFromJS();
        if (isHttpsPage()) {
            return "rtmps://rtmps." + host + "/" + RTMP_APP;
        } else {
            return "rtmp://" + host + ":" + RTMP_PORT + "/" + RTMP_APP;
        }
    }
}
}
