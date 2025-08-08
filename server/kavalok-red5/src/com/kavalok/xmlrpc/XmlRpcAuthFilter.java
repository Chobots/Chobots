package com.kavalok.xmlrpc;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class XmlRpcAuthFilter implements Filter {

  private static final String HEADER_NAME = "X-Kavalok-Secret";
  private static final String ENV_NAME = "KAVALOK_SECRET_KEY";

  @Override
  public void init(FilterConfig filterConfig) throws ServletException {}

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    if (!(request instanceof HttpServletRequest) || !(response instanceof HttpServletResponse)) {
      chain.doFilter(request, response);
      return;
    }

    HttpServletRequest httpRequest = (HttpServletRequest) request;
    HttpServletResponse httpResponse = (HttpServletResponse) response;

    String provided = httpRequest.getHeader(HEADER_NAME);
    String expected = System.getenv(ENV_NAME);

    if (expected == null || expected.isEmpty()) {
      httpResponse.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server auth not configured");
      return;
    }

    if (provided == null || !expected.equals(provided)) {
      httpResponse.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized XML-RPC request");
      return;
    }

    chain.doFilter(request, response);
  }

  @Override
  public void destroy() {}
}

