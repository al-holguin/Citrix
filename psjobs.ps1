#powershell method for splitting work with powershell jobs
#was comissioned to write this script to allow for the copying of hundred thousand
#user profile/documents folders for a NAS migration.
#Script runs X robocopies at a time.

# this is the job code $jobblock = {
param($jfrom,$jto,$jlogdate)
# accept the above variables across the job-context barrier #do something, robocopy?
}
foreach ($folder in $folderlist) {
$jobinfo = Start-Job $jobBlock -Arg $cfrom,$cto,$logdate
# limit to $nThreads, wait $sleepy seconds for to check if any jobs are finished
while (((get-job -state "Running").count) -ge $nThread){$tJobs=(get-job -state "Running").count;write-host
"[$tJobs] Jobs Running. Pausing $sleepy seconds." -fore red -background yellow;start-sleep $sleepy}
}
# report that all jobs have been started, wait for ramaining jobs to finish.
write-host "`n##############################`nAll jobs have been started. Waiting for remaining jobs to finish.`n##############################`n" -fore red -background white
while (((get-job -state "Running").count) -gt 0){$tJobs=(get-job -state "Running").count;write-host "[$tJobs] Jobs Running. Pausing $sleepy seconds." -fore red -background white;start-sleep $sleepy}
