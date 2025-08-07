package com.kavalok.constants {
import flash.external.ExternalInterface;

public class ConnectionConfig {
    public static function buildRtmpUrl():String {
        try {
            if (ExternalInterface.available) {
                var js:String =
                    "function() {" +
                    "  if (typeof window.rtmpConnectionString === 'string' && window.rtmpConnectionString.length > 0) {" +
                    "    return window.rtmpConnectionString;" +
                    "  }" +
                    "  return 'rtmp://' + window.location.hostname + ':8935/kavalok';" +
                    "}";

                var result:String = ExternalInterface.call(js);
                if (result && result.length > 0) {
                    return result;
                }
            }
        } catch (e:Error) {}
        return "rtmp://127.0.0.1:8935/kavalok";
    }
}
}
