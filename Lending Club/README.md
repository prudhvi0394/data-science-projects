### Lending Club loan risk prediction

#### Data Source & description: [https://www.kaggle.com/wordsforthewise/lending-club](https://www.kaggle.com/wordsforthewise/lending-club).
The data is loans lent on Lending Club platform from 2007 - 2019 along with all the details of users. It has almost 2 million rows and 151 features. 
I have used a subset of loans from 2018-19 financial year and have reduced the attributes as well as needed for my use.
 
## Motivation
- I have worked in an ecommerce company and lending was an essential part of the revenue generation. It motivated me to pursue data science as 
a career in general to understand the underwriting process and the variables which dictate loan amounts,time period, risk associated with businesses,individuals.

- Since this is a peer to peer platform we can use the models developed here to identify lucrative loans which would fetch money to the buyers.
Banks have a credit rating for every individual which classifies the risk of the loan.

- Our business opportunity lies in identifying the loans which are bad loans in the high interest rate category through a robust classification 
algorithm and present the same to our investors/lenders

## Assumptions

- Repayment status of the loan was used a target feature after dividing it into good loans and bad loans based on the following criteria:

  - Good loans: Current,Fully Paid,Grace period as good loans
  - Bad loans: Default,Late(16-30)&(31-120),Charged off


- There were some employment statuses which were not available so I have assumed them to be never employed and assigned that to 0

- I have chosen to work with the highest category risk loans so E category loans are subset which leads to a problem with imbalance in the data

## Modelling approach

- Before doing anything we would like to know what are the important features and in order to do that we need to take a look at the features 
available to the investors before investing since the dataset contains information which is available post the loan payment as well

-Post removing those features and checking feature importance we can visualize the features which are most important 
