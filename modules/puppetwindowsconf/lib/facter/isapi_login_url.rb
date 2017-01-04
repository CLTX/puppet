  Facter.add("isapi_login_url") do
    setcode do
	  env = Facter.value('machine_env')
	  case env
	   when /^PRD/
	     "auth.mycompany.com"
	   else
	     "tst-login.mydomain.mycompany.com"
       end
    end
  end  
  
  Facter.add("isapi_session_shares") do
    setcode do
	  env = Facter.value('machine_env')
	  case env
	   when /^PRD/
	     "yourdomain.mycompany.com\\pdfs\\Shares\\team01\\SSO"
	   else
	     "yourdomain.mycompany.com\\TDFS\\Shares\\team01\\SSO"
       end
    end
  end  
  
  Facter.add("SessionDir") do
    setcode do
	  env = Facter.value('machine_env')
	  case env
	   when /^PRD/
	     "\\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\SSO\\sessions"
	   else
	     "\\\\yourdomain.mycompany.com\\TDFS\\Shares\\team01\\SSO\\sessions"
      end
    end
  end
  
  Facter.add("SIDCookieName") do
    setcode do
	  env = Facter.value('machine_env')
	  case env
	   when /^PRD/
	     "CSSID"
	   else
	     "CSTSTSID"
      end
    end
  end
  
  Facter.add("LandingPageURL") do
    setcode do
	  env = Facter.value('machine_env')
	  case env
	   when /^PRD/
	     "http://my.mycompany.com/welcome/router.aspx"
	   else
	     "http://int-my.mydomain.mycompany.com/welcome/router.aspx"
      end
    end
  end
  
  Facter.add("NSLoginURL") do
    setcode do
	  env = Facter.value('machine_env')
	  case env
	   when /^PRD/
	     "http://www.netscoreonline.com/login/reappname03.pli"
	   else
	     "http://tst-ns.mydomain.mycompany.com/login/reappname03.pli"
      end
    end
end
	
