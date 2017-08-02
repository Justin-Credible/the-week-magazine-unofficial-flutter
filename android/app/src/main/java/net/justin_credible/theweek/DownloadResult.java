package net.justin_credible.theweek;

import java.util.HashMap;
import java.util.Map;

public class DownloadResult {

    public String message;
    public Boolean success;
    public Boolean cancelled;

    public DownloadResult(String message) {
        this.message = message;
        this.success = false;
        this.cancelled = false;
    }

    public Map<String, Object> toMap() {
        Map<String, Object> map = new HashMap<>();

        map.put("message", message);
        map.put("success", success);
        map.put("cancelled", cancelled);

        return map;
    }
}
