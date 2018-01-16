# R_Social_Media_Predictive_Model
## Synopsis: 
Collected and cleaned Facebook Post data to build predictive models that forecast if a proposed Facebook Post will have high levels of user engagement online.

## Motivation: 
Bayer Pharmaceutical’s over the counter brands, such as Coppertone and Claritin, have an online presence on social media.  The company seeks higher levels of user engagement on social media; more impressions online translates directly into more brand awareness and purchases.  The company’s preferred metric for evaluating posts is the number of likes. <br />
Our team worked with Bayer Pharmaceutical to develop a predictive model that can evaluate proposed Facebook Posts.  Our model can identify if a proposed post is likely to be a top performer – as defined as being in the top 20% of likes of all posts – or is likely to not be a top performer.  The 3-nearest neighbor model was used, it performed the best in comparison to models employing naive Bayes, decision trees, 5-nearest neighbors, and 10-nearest neighbors.  <br />
On our validation data set, our model had 83.02% accuracy overall.  Our model excelled at identifying non-top performing posts with a true negative rate of 96.06%.  While the model’s AUC was only 0.55, we viewed out model as a success because it was able to separate out low performing posts far better than Bayer Pharmaceutical was able to do without the model. <br />
We delivered this model to Bayer Pharmaceutical as an R Shiny application.  With this interactive package we created an interface for non-technical users to leverage our model.  These users can enter the brand, text, timing, and associated media of their post and see the forecasted performance levels. <br />
## Files:
ui.R – R Shiny user interface for users to submit Facebook Posts, depending on if copperMaster.csv or claritinMaster.csv is uploaded it can evaluate posts of each corresponding brand.
server.R – R Shiny server that cleans user submitted data and evaluates with the 3-nearnest neighbor algorithm. 
copperMaster.csv – Publically available data the Coppertone Facebook Page describing the brand’s Facebook posts.
claritinMaster.csv - Publically available data the Claritin Facebook Page describing the brand’s Facebook posts.

## Contributors: 
### Michael Turner, Project Manager and Data Scientist (Contributed to: server.R, ui.R)
### David Mitre Becerril: Data Scientist (Contributed to: server.R, ui.R)
### Tejas Bise: Data Scrapper 
### Annesha Ganguly: Competition Analyst 
### Team consulted for Bayer Pharmaceuticals in Measuring Social (94-823) at Carnegie Mellon University under Professor Ari Lightman.

## Disclaimer:
None of the data or code here was provided by Bayer Pharmaceuticals.  Consulting was focused on figuring out the needs of the clients and meeting those needs. 
