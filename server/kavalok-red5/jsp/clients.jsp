<%@ page import="java.util.Iterator, java.util.Date,
org.red5.server.api.IClient, com.kavalok.KavalokApplication,
java.util.Set, org.red5.server.so.SharedObjectScope,
com.kavalok.user.UserAdapter, com.kavalok.user.UserManager" %>
<pre>
<%

 Iterator<String> sharedObjNames = com.kavalok.KavalokApplication.getInstance().getSharedObjectNames(com.kavalok.KavalokApplication.getInstance().getScope()).iterator();
 int totalListeners = 0;
 int maxListeners = 0;
 int activeListeners = 0;
 int totalSends = 0;

 while (sharedObjNames.hasNext()) {
 	String name = sharedObjNames.next();
 	out.println("sharedObjName: "+name);
 	SharedObjectScope so = (SharedObjectScope)KavalokApplication.getInstance().getSharedObject(name);
 	out.println("so.TotalListeners "+so.getStatistics().getTotalListeners());
 	out.println("so.MaxListeners "+so.getStatistics().getMaxListeners());
 	out.println("so.ActiveListeners "+so.getStatistics().getActiveListeners());
 	out.println("so.TotalSends "+so.getStatistics().getTotalSends());
 	out.println("");
 	activeListeners+=so.getStatistics().getActiveListeners();
 	totalSends+=so.getStatistics().getTotalSends();
 }
 	out.println("activeListeners "+activeListeners);
 	out.println("totalSends "+totalSends+" \n");

%>
</pre>
<%
 Iterator<IClient> clients = KavalokApplication.getInstance().getClients().iterator();
   int i=0;
   while (clients.hasNext()) {
     IClient client = clients.next();
     UserAdapter user = (UserAdapter) client.getAttribute(UserManager.ADAPTER);
     if(user!=null && user.getLogin()!=null && user.getUserId()!=null){
       i++;
   %>
        <%="Live client login: "+user.getUserId()+" "+user.getLogin()+ " last tick: "+ user.getLastTick()+" creationTime: "+new Date(client.getCreationTime())%><br>
   <%}
   }
  %>
  <%="Clients count:"+KavalokApplication.getInstance().getClients().size()%><br><%="Alive Clients count: "+i %>