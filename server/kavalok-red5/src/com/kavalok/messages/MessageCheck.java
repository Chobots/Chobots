package com.kavalok.messages;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;

import com.kavalok.utils.Levenshtein;

public class MessageCheck {

  private static int BAD_WORD_DISTANCE = 2;

  private static String DELIMITERS =
      " |`|~|\\!|@|#|$|\\%|\\^|\\&|\\*|\\(|\\)|-|_|=|\\+|\\[|\\]|\\{|\\}|;|:|\'|\"|,|<|\\.|>|/|\\?|\\|\n";

  private static Pattern EMAIL_REGEXP =
      Pattern.compile("(\\s|^)[a-zA-Z\\.]+?@+[a-zA-Z\\.]+?(\\s|$)");

  private static Pattern URL_REGEXP =
      Pattern.compile(
          "(((ht|f)tp(s?):\\/\\/)|(www\\.[^ \\[\\]\\(\\)\\n\\r\\t]+)|(([012]?[0-9]{1,2}\\.){3}[012]?[0-9]{1,2})\\/)([^ \\[\\]\\(\\),;\"'<>\\n\\r\\t]+)([^\\. \\[\\]\\(\\),;'\"'<>\\n\\r\\t])|(([012]?[0-9]{1,2}\\.){3}[012]?[0-9]{1,2})");

  private static String NUMBERS_DELIMITER = "().-: ";

  private static int ALLOWED_NUMBER_COUNT = 5;

  public MessageCheck(Session session) {
    super();
  }

  public static void main(String[] args) {
    Matcher regexMatcher =
        EMAIL_REGEXP.matcher(
            "Dear Moderator, the player ' moderator ' asdasdasdasdasdasdkljaslkjasdsad@@@@@.com @@@@@@@@@@@@@@@@@@@@@@@  http://porno.com is breaking the rules by impersonating Moderators  by using his name, by pretending he is a Moderator and get advantage of that.   Kind Regards Firefly");
    if (regexMatcher.find()) {
      regexMatcher.group();
    }
  }

  public MessageCheckResult check(String message) {
    MessageSafety resultSafety = MessageSafety.SAFE;
    String resultPart = null;
    List<String> parts = new ArrayList<String>(Arrays.asList(message.split(DELIMITERS)));
    while (parts.remove("")) ;
    List<String> parts2 = new ArrayList<String>();
    for (int i = 0; i < parts.size(); i++) {
      String dupRemoved = removeDublications(parts.get(i));
      parts2.add(dupRemoved);
    }
    parts.add(" --- "); // adding for case with short messages, ex. "s....e...x"
    // would tell sexsex is bad word without this delimiter.
    parts.addAll(parts2);
    concatPossibleWords(parts);
    parts.add(message);
    String numberCheckResult = checkNumber(message);
    if (numberCheckResult != null) {
      resultPart = numberCheckResult;
      resultSafety = MessageSafety.SKIP;
    }

    Matcher regexMatcher;
    for (String part : parts) {
      regexMatcher = EMAIL_REGEXP.matcher(part);
      if (regexMatcher.find()) {
        resultPart = regexMatcher.group();
        resultSafety = MessageSafety.SKIP;
        break;
      }
    }

    regexMatcher = URL_REGEXP.matcher(message);
    if (regexMatcher.find()) {
      resultPart = regexMatcher.group();
      resultSafety = MessageSafety.SKIP;
    }

    if (resultSafety == MessageSafety.SAFE) {
      List<String> blockWordsList = WordsCache.getInstance().get(MessageSafety.BAD);
      List<String> skipWordsList = WordsCache.getInstance().get(MessageSafety.SKIP);
      List<String> reviewWordsList = WordsCache.getInstance().get(MessageSafety.REVIEW);
      List<String> allowedWordsList = WordsCache.getInstance().get(MessageSafety.SAFE);
      for (String part : parts) {
        String lowerPart = part.toLowerCase();

        if (blockWordsList.contains(lowerPart)) {
          resultPart = lowerPart;
          resultSafety = MessageSafety.BAD;
          break;
        }
        if (!MessageSafety.REVIEW.equals(resultSafety)
            && (reviewWordsList.contains(lowerPart)
                || reviewWordsList.contains(" " + lowerPart)
                || reviewWordsList.contains(lowerPart + " ")
                || reviewWordsList.contains(" " + lowerPart + " ")
                || hasPartOfWord(lowerPart, reviewWordsList))) {
          resultPart = lowerPart;
          resultSafety = MessageSafety.REVIEW;
        }
        if (allowedWordsList.contains(lowerPart)) {
          String fullMessage = parts.get(parts.size() - 1);
          fullMessage = StringUtils.replace(fullMessage, " " + lowerPart + " ", "");

          if (fullMessage.startsWith(lowerPart + " "))
            fullMessage = StringUtils.replaceOnce(fullMessage, lowerPart + " ", "");

          if (fullMessage.endsWith(" " + lowerPart)) {
            int index = fullMessage.lastIndexOf(" " + lowerPart);
            if (index == 0) {
              fullMessage = "";
            } else {
              fullMessage = fullMessage.substring(0, index - 1);
            }
          }

          parts.set(parts.size() - 1, fullMessage);
          continue;
        }
        if (skipWordsList.contains(lowerPart)
            || skipWordsList.contains(" " + lowerPart)
            || skipWordsList.contains(lowerPart + " ")
            || skipWordsList.contains(" " + lowerPart + " ")
            || hasPartOfWord(lowerPart, skipWordsList)) {
          resultPart = lowerPart;
          resultSafety = MessageSafety.SKIP;
          break;
        }
        if (blockWordsList.contains(lowerPart)
            || blockWordsList.contains(" " + lowerPart)
            || blockWordsList.contains(lowerPart + " ")
            || blockWordsList.contains(" " + lowerPart + " ")
            || hasPartOfWord(lowerPart, blockWordsList)) {
          resultPart = lowerPart;
          resultSafety = MessageSafety.BAD;
          break;
        }
        for (String blockWord : blockWordsList) {
          if (Levenshtein.distance(lowerPart, blockWord) <= BAD_WORD_DISTANCE) {
            resultPart = lowerPart;
            resultSafety = MessageSafety.SUSPICIOUS;
          }
          // if (canTranslit(blockWord)) {
          // String translit = translit(blockWord);
          // if (Levenshtein.distance(lowerPart, translit) <= BAD_WORD_DISTANCE)
          // {
          // resultPart = lowerPart;
          // resultSafety = MessageSafety.SUSPICIOUS;
          // }
          //
          // }
        }
      }
    }
    return new MessageCheckResult(resultPart, resultSafety);
  }

  private boolean hasPartOfWord(String testWord, List<String> words) {
    for (String word : words) if (testWord.contains(word)) return true;

    return false;
  }

  private void concatPossibleWords(List<String> parts) {
    String[] words = new String[parts.size()];
    words = parts.toArray(words);
    boolean partFound = false;

    String newPart = "";
    String newPartWithPrev = "";
    String partTrimmed = "";

    for (int i = 0; i < words.length; i++) {
      partTrimmed = words[i].trim();
      if (partTrimmed.length() == 1 || partTrimmed.length() == 2) {
        if (!partFound) {
          newPart = newPart + partTrimmed;
          if (i > 0 && words[i - 1].trim().length() <= 3) {
            newPartWithPrev = words[i - 1].trim() + partTrimmed;
          }
          partFound = true;
        } else {
          newPart = newPart + partTrimmed;
          if (newPartWithPrev.length() > 0) {
            newPartWithPrev = newPartWithPrev + partTrimmed;
          }
        }
      } else if (partFound) {
        partFound = false;
        addParts(parts, newPart, newPartWithPrev, partTrimmed);
        newPart = "";
        newPartWithPrev = "";
      }
      if (partFound && (i + 1) == words.length) {
        partTrimmed = "";
      }
    }
    if (partFound) {
      addParts(parts, newPart, newPartWithPrev, partTrimmed);
    }
  }

  private void addParts(
      List<String> parts, String newPart, String newPartWithPrev, String partTrimmed) {
    if (!parts.contains(newPart)) parts.add(newPart);

    if (newPartWithPrev.length() > 0 && !parts.contains(newPartWithPrev))
      parts.add(newPartWithPrev);

    String partWithNext = newPart + partTrimmed;
    if (!parts.contains(partWithNext)) parts.add(partWithNext);
  }

  private String checkNumber(String message) {
    StringBuffer result = null;
    int foundNumbersCount = 0;
    for (int i = 0; i < message.length(); i++) {

      if (foundNumbersCount > ALLOWED_NUMBER_COUNT) {
        return result.toString();
      }
      if ((message.charAt(i) >= '0' && message.charAt(i) <= '9')) {
        if (foundNumbersCount == 0) {
          result = new StringBuffer();
        }
        result.append(message.charAt(i));
        foundNumbersCount++;
      } else if (foundNumbersCount > 0 && NUMBERS_DELIMITER.indexOf(message.charAt(i)) >= 0) {
        result.append(message.charAt(i));
      } else if (foundNumbersCount > 0) {
        foundNumbersCount = 0;
      }
    }

    return null;
  }

  private String removeDublications(String source) {
    StringBuilder builder = new StringBuilder();
    int index = 0;
    while (index < source.length()) {
      char letter = source.charAt(index);
      builder.append(letter);
      index++;
      while (index < source.length() && source.charAt(index) == letter) {
        index++;
      }
    }
    return builder.toString();
  }
}
