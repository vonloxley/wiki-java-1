<!--
    @(#)xwikilinksearch.jsp 0.02 27/01/2017
    Copyright (C) 2011 - 2017 MER-C
  
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.
  
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->

<%@ include file="header.jsp" %>
<%@ page contentType="text/html" pageEncoding="UTF-8" 
    trimDirectiveWhitespaces="true"%>

<%
    request.setAttribute("toolname", "Cross-wiki linksearch");

    String domain = request.getParameter("link");
    if (domain != null)
        domain = ServletUtils.sanitizeForAttribute(domain);
    else
        domain = "";

    String set = request.getParameter("set");
    if (set == null)
        set = "top20";

    String wikiinput = request.getParameter("wiki");
    if (wikiinput != null)
        wikiinput = ServletUtils.sanitizeForAttribute(wikiinput);

    boolean https = (request.getParameter("https") != null);
    boolean mailto = (request.getParameter("mailto") != null);

    String temp = request.getParameter("ns");
    boolean mainns = temp != null && temp.equals("0");
    int[] ns = mainns ? new int[] { Wiki.MAIN_NAMESPACE } : new int[0];
%>

<!doctype html>
<html>
<head>
<link rel=stylesheet href="styles.css">
<title><%= request.getAttribute("toolname") %></title>
<script type="text/javascript" src="XWikiLinksearch.js"></script>
</head>

<body>
<p>
This tool searches various Wikimedia projects for a specific link. Enter a 
domain name (example.com, not *.example.com or http://example.com) below. A 
timeout is more likely when searching for more wikis or protocols.

<form name="spamform" action="./linksearch.jsp" method=GET>
<table>
<tr>
    <td><input id="radio_multi" type=radio name=radio<%= (wikiinput == null) ?
         " checked" : "" %>>
    <td>Wikis to search:
    <td><select name=set id=set<%= (wikiinput != null) ? " disabled" : "" %>>
            <option value="top20"<%= set == "top20" ? " selected" : ""%>>Top 20 Wikipedias</option>
            <option value="top40"<%= set == "top40" ? " selected" : ""%>>Top 40 Wikipedias</option>
            <option value="major"<%= set == "major" ? " selected" : ""%>>Major Wikimedia projects</option>
        </select>
        
<tr>
    <td><input id="radio_single" type=radio name=radio<%= (wikiinput != null) ?
         " checked" : "" %>>
    <td>Single wiki:
    <td><input type=text id=wiki name=wiki <%= (wikiinput != null) ? "value=" + 
        wikiinput : "disabled" %>>
        
<tr>
    <td colspan=2>Domain to search:
    <td><input type=text name=link required value="<%= domain %>">
        
<tr>
    <td colspan=2>Additional protocols:
    <td><input type=checkbox name=https value=1<%= (https || domain.isEmpty()) ?
        " checked" : "" %>>HTTPS
        <input type=checkbox name=mailto value=1<%= mailto ? " checked" : "" %>>mailto

<tr>
    <td><input type=checkbox name=ns value=0<%= mainns ? " checked" : "" %>>
    <td colspan=3>Main namespace only?

</table>
<br>
<input type=submit value=Search>
</form>

<%
    if (!domain.isEmpty())
    {
        out.println("<hr>");
        Map<Wiki, List[]> results = null;
        if (wikiinput == null)
        {
            switch (set)
            {
                case "top20":
                    results = AllWikiLinksearch.crossWikiLinksearch(domain, 
                        AllWikiLinksearch.TOP20, https, mailto, ns);
                    break;
                case "top40":
                    results = AllWikiLinksearch.crossWikiLinksearch(domain, 
                        AllWikiLinksearch.TOP40, https, mailto, ns);
                    break;
                case "major":
                    results = AllWikiLinksearch.crossWikiLinksearch(domain, 
                        AllWikiLinksearch.MAJOR_WIKIS, https, mailto, ns);
                    break;
                default:
    %>
    <span class="error">Invalid wiki set selected!</span>
    <%@ include file="footer.jsp" %>
    <%
                    return;
            }
        }
        else   
            results = AllWikiLinksearch.crossWikiLinksearch(domain, new Wiki[] 
                { new Wiki(wikiinput) }, https, mailto, ns);

        for (Map.Entry<Wiki, List[]> entry : results.entrySet())
        {
            Wiki wiki = entry.getKey();
            out.println("<h3>" + wiki.getDomain() + "</h3>");
            out.println(ParserUtils.linksearchResultsToHTML(entry.getValue(), wiki, domain));
        }
    }
%>
<%@ include file="footer.jsp" %>