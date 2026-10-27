# Cambia las pruebas de go-sync (command/ y datastore/) para que usen el almacén SQLite y la caché en memoria.
import re, sys
for p in sys.argv[1:]:
    s = open(p).read()
    s = s.replace('dynamo *datastore.Dynamo', 'dynamo *SQLite')
    s = re.sub(r'\tdatastore\.Table = "[^"]*".*\n', '', s)
    s = s.replace('suite.dynamo, err = datastore.NewDynamo()', 'suite.dynamo, err = nuevaDB(), nil')
    s = s.replace('cache.NewCache(cache.NewRedisClient())', 'cache.NewCache(NuevaMemoria())')
    s = s.replace('datastoretest.ResetTable(suite.dynamo)', 'func() error { suite.dynamo = nuevaDB(); return nil }()')
    s = s.replace('datastoretest.DeleteTable(suite.dynamo)', 'suite.dynamo.Close()')
    s = s.replace('datastoretest.ScanTagItems(suite.dynamo)', 'scanTags(suite.dynamo)')
    s = s.replace('datastoretest.ScanSyncEntities(suite.dynamo)', 'scanSync(suite.dynamo)')
    s = s.replace('datastoretest.ScanClientItemCounts(suite.dynamo)', 'scanCounts(suite.dynamo)')
    s = s.replace('\t"github.com/brave/go-sync/datastore/datastoretest"\n', '')
    if 'datastoretest' in s or 'NewDynamo' in s or 'NewRedisClient' in s:
        sys.exit(f'{p}: queda algo de DynamoDB o Redis sin adaptar')
    open(p, 'w').write(s)
