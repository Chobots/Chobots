<%@ page import="java.util.Iterator, java.util.Date,
org.red5.server.api.IClient, com.kavalok.KavalokApplication,
java.util.Set, org.red5.server.so.SharedObjectScope,
com.kavalok.user.UserAdapter, com.kavalok.user.UserManager" %><%Iterator<IClient> clients = KavalokApplication.getInstance().getClients().iterator();   int i=0;
   while (clients.hasNext()) {
     IClient client = clients.next();
     UserAdapter user = (UserAdapter) client.getAttribute(UserManager.ADAPTER);
     if(user!=null && user.getLogin()!=null && user.getUserId()!=null){
       i++;%><%="\""+user.getLogin()+"\",\""+user.getUserId()+"\",\""+user.getAccessType()+"\""%><br><%}   }  %>
       
 <br><br><br><br><br><br>      
Bad clients:
<br>       
<%clients = KavalokApplication.getInstance().getClients().iterator();    i=0;
   while (clients.hasNext()) {
     IClient client = clients.next();
     UserAdapter user = (UserAdapter) client.getAttribute(UserManager.ADAPTER);
     if(user!=null && (user.getLogin()==null || user.getUserId()==null)){
       i++;%><%="\""+user.getCreationStackTrace()%><br>
<%}

if(user==null){%>
   <%="\""+client.getConnections().iterator().next().getRemoteAddress()+"\""%>	<br>

<%}

 }  %>       
<br><br><br><br><br><br><br>       
Ok clients:
<br>       
<%clients = KavalokApplication.getInstance().getClients().iterator();    i=0;
   while (clients.hasNext()) {
     IClient client = clients.next();
     UserAdapter user = (UserAdapter) client.getAttribute(UserManager.ADAPTER);
     if(user!=null && user.getLogin()!=null && user.getUserId()!=null){
       i++;%><%="\""+user.getCreationStackTrace()%><br><br><%}   }  %>              