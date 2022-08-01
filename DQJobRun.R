#r script to run weekly DQ Report and email to syndromic staff (rishi.kowalski + kelley.bemis)
#Created 6/10/22 by rishi.kowalski@cookcountyhealth.org

#Render report
library(rmarkdown)
library(rJava)
library(mailR)
library(keyring)
Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/pandoc")
code_fpath <- key_get("rk_code_fpath")
repo_path <- paste0(code_fpath, "nssp-data-quality-report/")  #not sure why but task scheduler doesn't seem to work with relative paths or getwd()
rmarkdown::render(paste0(repo_path, "nssp-dq-weekly-report.Rmd"))


#Email report or failure notice

if(as.Date(file.mtime(paste0(repo_path,"nssp-dq-weekly-report.html"))) == Sys.Date()){
  
  #send email
  send.mail(from = "noreply@cookcountyhhs.org",
            to =  c("rishi.kowalski@cookcountyhealth.org", "kelley.bemis@cookcountyhealth.org"), 
            subject = "Weekly NSSP DQ Report",
            body = "Please see the weekly data quality report attached.",
            smtp = list(host.name = "cchhssync02.cchhs.local", #port = 25,
                        user.name = key_get("rk_email"),
                        passwd = key_get("office365"), tls = TRUE),
            attach.files = paste0(repo_path, "nssp-dq-weekly-report.html"),
            authenticate = TRUE,
            send = TRUE) 
  
  #rename and move file to appropriate folder in documents
  docs_fpath <- key_get("rk_docs_fpath")
  tgt_path <- paste0(docs_fpath, "nssp-reports/dq-reports/")
  new_fname <- paste0("nssp-dq-weekly-report-", format(Sys.Date(), "%m-%d-%Y"), ".html")
  file.rename(from = paste0(repo_path,"nssp-dq-weekly-report.html"),
              to = paste0(repo_path, new_fname))
  
  file.copy(from = paste0(repo_path,"nssp-dq-weekly-report-", format(Sys.Date(), "%m-%d-%Y"), ".html"),
            to = paste0(tgt_path, new_fname))
  file.remove(paste0(repo_path, new_fname))
  
} else { 
  
  send.mail(from = "noreply@cookcountyhhs.org",
            to = c("rishi.kowalski@cookcountyhealth.org", "kelley.bemis@cookcountyhealth.org"),
            subject = "ATTENTION: Weekly DQ Report Script Failed",
            body = "Please check the script and troubleshoot.",
            smtp = list(host.name = "cchhssync02.cchhs.local", #port = 25,
                        user.name = key_get("rk_email"),
                        passwd = key_get("office365"), tls = TRUE),
            authenticate = TRUE,
            send = TRUE)
  
}