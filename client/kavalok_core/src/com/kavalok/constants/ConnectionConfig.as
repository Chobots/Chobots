package com.kavalok.constants {
import flash.external.ExternalInterface;

public class ConnectionConfig {
    public static const RTMP_PORT:String = "8935";
    public static const RTMP_APP:String = "kavalok";
    private static const DEFAULT_HOST:String = "127.0.0.1";

    private static function getHostFromJS():String {
        trace("ConnectionConfig: getHostFromJS() called");
        try {
            if (ExternalInterface.available) {
                trace("ConnectionConfig: ExternalInterface is available");
                var js:String =
                    "function() {" +
                    "  if (typeof window.rtmpHostname === 'string' && window.rtmpHostname.length > 0) {" +
                    "    return window.rtmpHostname;" +
                    "  }" +
                    "  return window.location.hostname;" +
                    "}";

                var result:String = ExternalInterface.call(js);
                trace("ConnectionConfig: getHostFromJS() result: " + result);
                if (result && result.length > 0) {
                    return result;
                }
            } else {
                trace("ConnectionConfig: ExternalInterface is NOT available");
            }
        } catch (e:Error) {
            trace("ConnectionConfig: getHostFromJS() error: " + e.message);
        }
        trace("ConnectionConfig: getHostFromJS() returning DEFAULT_HOST: " + DEFAULT_HOST);
        return DEFAULT_HOST;
    }

    private static function isHttpsPage():Boolean {
        trace("ConnectionConfig: isHttpsPage() called");
        try {
            if (ExternalInterface.available) {
                trace("ConnectionConfig: ExternalInterface is available for HTTPS check");
                var js:String =
                    "function() {" +
                    "  return window.location.protocol === 'https:';" +
                    "}";
                var result:Boolean = ExternalInterface.call(js) === true;
                trace("ConnectionConfig: isHttpsPage() result: " + result);
                return result;
            } else {
                trace("ConnectionConfig: ExternalInterface is NOT available for HTTPS check");
            }
        } catch (e:Error) {
            trace("ConnectionConfig: isHttpsPage() error: " + e.message);
        }
        trace("ConnectionConfig: isHttpsPage() returning false (default)");
        return false;
    }

    public static function buildRtmpUrl():String {
        trace("ConnectionConfig: buildRtmpUrl() called");
        var host:String = getHostFromJS();
        trace("ConnectionConfig: buildRtmpUrl() host: " + host);
        
        var isHttps:Boolean = isHttpsPage();
        trace("ConnectionConfig: buildRtmpUrl() isHttps: " + isHttps);
        
        var url:String;
        if (isHttps) {
            url = "rtmps://" + host + "/" + RTMP_APP;
            trace("ConnectionConfig: buildRtmpUrl() using RTMPS protocol");
        } else {
            url = "rtmp://" + host + ":" + RTMP_PORT + "/" + RTMP_APP;
            trace("ConnectionConfig: buildRtmpUrl() using RTMP protocol");
        }
        
        trace("ConnectionConfig: buildRtmpUrl() final URL: " + url);
        return url;
    }
}
}
