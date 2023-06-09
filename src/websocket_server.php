use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;

require 'vendor/autoload.php';

class MyWebSocketServer implements MessageComponentInterface
{
    public function onOpen(ConnectionInterface $connection)
    {
        // New websocket connection opened
        echo "New connection opened: {$connection->resourceId}\n";
    }

    public function onMessage(ConnectionInterface $from, $message)
    {
        // Handle incoming message from a client
        echo "Received message from {$from->resourceId}: {$message}\n";

        // Send a response back to the client
        $from->send("Server says: {$message}");
    }

    public function onClose(ConnectionInterface $connection)
    {
        // Websocket connection closed
        echo "Connection closed: {$connection->resourceId}\n";
    }

    public function onError(ConnectionInterface $connection, \Exception $exception)
    {
        // Error occurred in the websocket connection
        echo "An error occurred in connection {$connection->resourceId}: {$exception->getMessage()}\n";
        $connection->close();
    }
}

$server = new \Ratchet\App('localhost', 8080);
$server->route('/', new MyWebSocketServer(), ['*']);
$server->run();
