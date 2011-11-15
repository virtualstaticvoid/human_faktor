select a.id, a.subdomain, min(e.start_date)
from accounts as a
  left join employees as e
   on a.id = e.account_id
group by a.id, a.subdomain