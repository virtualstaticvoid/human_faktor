select c.title, a.*
from accounts as a
 left join countries as c
  on a.country_id = c.id;