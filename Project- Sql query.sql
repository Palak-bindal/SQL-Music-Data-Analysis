/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

select first_name, last_name, title from employee
order by levels desc 
limit 1;

/* Q2: Which countries have the most Invoices? */

select billing_country, count(*) from invoice
group by billing_country
order by count(*) desc
limit 5;

/* Q3: What are top 3 values of total invoice? */

select total from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_country, billing_city, SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_country, billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, first_name, last_name,  sum(total) from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id
order by sum(total) desc
limit 1



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct(email), first_name, last_name, genre.name as genre_name from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name ='Rock'
order by email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.name, count(track_id) from artist
join album on album.artist_id = artist.artist_id
join track on track.album_id = album.album_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.name 
order by count(track_id) desc
limit 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds from track 
where milliseconds>(select AVG(milliseconds) from track )
order by milliseconds desc



/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on most sold artists? Write a query to return customer name, artist name and total spent */

with best_selling_artist as
(select artist.artist_id, artist.name as artist_name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join invoice_line on track.track_id = invoice_line.track_id
group by artist.artist_id
order by 3 desc
limit 1)

select c.customer_id, c.first_name ,c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as total_spend
from customer c
join invoice i on c.customer_id =i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album a on a.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = a.artist_id
group by 1,2,3,4
order by 5 desc;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as
 (SELECT COUNT(invoice_line.quantity) AS purchases, invoice.billing_country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC)
select * from popular_genre where rowno<=1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with most_spend_details as
(select i.billing_country, i.customer_id, sum(il.unit_price*il.quantity) as total_spent,
 row_number() over(partition by billing_country order by sum(il.unit_price*il.quantity) desc ) as row_no
from invoice_line il
join invoice i on il.invoice_id = i.invoice_id
group by 1,2
order by 1 asc,3 desc
)

select msd.*,c.first_name, c.last_name from most_spend_details msd
join customer c
on msd.customer_id = c.customer_id
where row_no<=1
order by 1;

