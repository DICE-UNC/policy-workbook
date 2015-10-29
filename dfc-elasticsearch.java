// use Elastic search query to retrieve list of logEntry (events)
//log?[fromDate={fromDate}][&toDate={toDate}][&event={event}][&pidFilter={pidFilter}][&start={start}][&count={count}]
@Override
public Log getLogs(
Date fromDate,
Date toDate,
EventsEnum event,
String pidFilter,
int startIdx,
int count)
throws NoNodeAvailableException {

	boolean datesExist = true;
	if (fromDate == null && toDate == null) {
		datesExist = false;
	}
			
	// restrict search to DataONE exposed data objects
	// get this list from the Handle server
	// should return something like this:
// "\"/dfc3/home/rods/fabfile.py2\".*|\"/dfc3/home/rods/fabfile.py3\".*"
	String uriRegex = null;
	try {
		uriRegex = getDataOneDataObjectsRegex();
	} catch (JargonException e) {
		logger.error("error getting DataOne uids and converting to regex");
		throw new NoNodeAvailableException(e.getMessage());
	}

// get elasticsearch properties
	PropertiesLoader loader = new PropertiesLoader();
	String elasticsearchDNS = 
loader.getProperty("irods.dataone.events.elasticsearch.dns");
int elasticsearchport =	Integer.parseInt(loader.getProperty("irods.dataone.events.elasticsearch.port"));
	String searchIndex = 
loader.getProperty("irods.dataone.events.elasticsearch.searchindex");
	String searchType = 
loader.getProperty("irods.dataone.events.elasticsearch.searchtype");
	String clusterName = 
loader.getProperty("irods.dataone.events.elasticsearch.cluster.name");
	String rangeField = "created";

	BoolQueryBuilder boolQuery = QueryBuilders.boolQuery()
.must(QueryBuilders.matchQuery("type", "databook.persistence.rule.rdf.ruleset.Access"));
if (event  != null) {
		boolQuery.must(QueryBuilders.matchQuery("title",event.getDatabookEvent()));
	}
			
	if (uriRegex != null && !uriRegex.isEmpty()) {
		boolQuery.must(QueryBuilders.regexpQuery("uri", uriRegex));
	}

	// Note that date time precision is limited to one millisecond.
	RangeFilterBuilder filterBuilder = FilterBuilders.rangeFilter(rangeField);
	if (datesExist) {
		if (fromDate != null) {
			filterBuilder
			.from(fromDate.getTime())
			.includeLower(true);
		}
		else {
			filterBuilder
.from(0)
.includeLower(true);
		}
		if (toDate != null) {
			filterBuilder
			.to(toDate.getTime())
			.includeUpper(false);
		}
		else {
			filterBuilder
			.to(System.currentTimeMillis())
			.includeUpper(false);
		}
	}

	logger.info("creating elastic search transport client: dns={}, port={}", elasticsearchDNS, elasticsearchport);
	Settings settings = ImmutableSettings.settingsBuilder() 
			       .put("cluster.name", clusterName).build();
	Client client = null;
	if(elasticsearchDNS != null && elasticsearchDNS.length() > 0) {
		client = new TransportClient(settings)
	       		.addTransportAddress(new InetSocketTransportAddress(elasticsearchDNS, elasticsearchport));
	}
	else {
		client = new TransportClient(settings)
       			.addTransportAddress(new InetSocketTransportAddress("localhost", 9300));
	}
	
	SearchRequestBuilder srBuilder = client.prepareSearch(searchIndex)
					.setTypes(searchType)
					.setQuery(boolQuery)
					.setFrom(startIdx).setSize(startIdx + count);
	if (datesExist) {
		srBuilder.setPostFilter(filterBuilder);
	}
	logger.info("getLogs: built search request: {}", srBuilder.toString());
			
	SearchResponse response = srBuilder.execute().actionGet();
	logger.info("getLogs: got search response: {}", response.toString());
			
	SearchHit[] searchHits = response.getHits().getHits();
	Log log = new Log();
	if (searchHits.length > 0) {
		// now put retrieved data into Log object
		try {
			log = copyHitsToLog(startIdx, count, response.getHits().getTotalHits(), searchHits);
		} catch (JargonException e) {
			logger.error("error copying elastic search hits into Log entries");
			throw new NoNodeAvailableException(e.getMessage());
		}
	}

	return log;
}
