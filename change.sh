git filter-repo --commit-callback "
  if commit.author_email == b'alexander.komarov@ibm.com':
      commit.author_name = b'akomakom'
      commit.author_email = b'regs@akom.net'
  if commit.committer_email == b'alexander.komarov@ibm.com':
      commit.committer_name = b'akomakom'
      commit.committer_email = b'regs@akom.net'
" $@
