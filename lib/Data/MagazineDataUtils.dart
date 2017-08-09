
import "Article.dart";

class MagazineDataUtils {

    static String getCoverImageURL(List<Article> articles) {

        if (articles == null) {
            return null;
        }

        for (var article in articles) {

            if (article.pageType == "cover") {
                return article.imageURI;
            }
        }

        return null;
    }

    static Map<String, List<Article>> getArticlesBySection(List<Article> articles, bool includeCoverPage, bool includeIndexPages) {

        Map<String, List<Article>> map = new Map<String, List<Article>>();

        if (articles == null) {
            return map;
        }

        for (var article in articles) {

            if (article.section == null) {
                continue;
            }

            if (article.pageType == "cover" && !includeCoverPage) {
                continue;
            }

            if (article.pageType == "index" && !includeIndexPages) {
                continue;
            }

            if (!map.containsKey(article.section)) {
                map[article.section] = new List<Article>();
            }

            map[article.section].add(article);
        }

        return map;
    }
}