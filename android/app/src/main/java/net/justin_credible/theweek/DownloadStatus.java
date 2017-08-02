package net.justin_credible.theweek;

import java.util.HashMap;
import java.util.Map;

public class DownloadStatus {

    public Boolean inProgress;
    public String id;
    public String statusText;
    public Integer percentage;

    public DownloadStatus() {
        inProgress = false;
    }

    public Map<String, Object> toMap() {

        Map<String, Object> map = new HashMap<>();

        map.put("inProgress", inProgress);
        map.put("id", id);
        map.put("statusText", statusText);
        map.put("percentage", percentage);

        return map;
    }
}
