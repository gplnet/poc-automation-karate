@REQ_MARVEL-001 @characterApiV1
Feature: Test de API súper simple

  Background:
    * configure ssl = true
    * url "http://bp-se-test-cabcd9b246a5.herokuapp.com"
    * def apiUser = 'caba'
    * header Accept = 'application/json'
    * header Content-Type = 'application/json'


  @id:1 @getAll @casoPositivo
  Scenario: T-MARVEL-001-CA1 - Obtener todos los personajes y validar la estructura
    Given path apiUser, 'api', 'characters'
    When method get
    Then status 200
    * match each response == { "id": '#number', "name": '#string', "alterego": '#string', "description": '#string', "powers": '#array' }



  @id:2 @crudFlow @casoPositivo
  Scenario: T-MARVEL-001-CA2 - Flujo CRUD completo de un personaje

    * print '--- Paso 1: Creando un personaje ---'
    * def uniqueName = 'Phoenix-' + java.util.UUID.randomUUID()
    * def requestBody = { "name": "#(uniqueName)", "alterego": "Jean Grey", "description": "Omega-level mutant", "powers": ["Telepathy", "Telekinesis"] }
    Given path apiUser, 'api', 'characters'
    And request requestBody
    When method post
    Then status 201
    * def characterId = response.id
    * print 'Personaje creado con ID:', characterId
    * match response.name == uniqueName

    * print '--- Paso 2: Verificando el personaje creado ---'
    * path apiUser, 'api', 'characters', characterId
    * method get
    * status 200
    * match response.id == characterId
    * match response.name == uniqueName

    * print '--- Paso 3: Actualizando el personaje ---'
    * def updatedRequestBody = { "name": "#(uniqueName)", "alterego": "Jean Grey", "description": "Updated: Host of the Phoenix Force", "powers": ["Telepathy", "Telekinesis", "Cosmic Pyrokinesis"] }
    * path apiUser, 'api', 'characters', characterId
    * request updatedRequestBody
    * method put
    * status 200
    * match response.description == "Updated: Host of the Phoenix Force"

    * print '--- Paso 4: Eliminando el personaje ---'
    * path apiUser, 'api', 'characters', characterId
    * method delete
    * status 204

    * print '--- Paso 5: Verificando la eliminación ---'
    * path apiUser, 'api', 'characters', characterId
    * method get
    * status 404
    * match response.error == "Character not found"

  @id:3 @create @casoNegativo
  Scenario: T-MARVEL-001-CA3 - Intentar crear un personaje con campos requeridos vacíos
    * print "--- Test Negativo: POST con campos vacíos ---"
    Given path apiUser, 'api', 'characters'
    And request { "name": "", "alterego": "", "description": "", "powers": [] }
    When method post
    Then status 400
    * match response == { "name": "Name is required", "alterego": "Alterego is required", "description": "Description is required", "powers": "Powers are required" }

  @id:4 @create @casoNegativo @duplicado
  Scenario: T-MARVEL-001-CA4 - Intentar crear un personaje con un nombre que ya existe
    * print "--- Test Negativo: POST con nombre duplicado ---"

    * print "Setup: Asegurando que 'Iron Man' con ID 1 existe..."
    Given path apiUser, 'api', 'characters', 2
    And request { "id": 2, "name": "Iron Man", "alterego": "Tony Stark", "description": "Setup character", "powers": [Invisibility] }
    When method put
    Then status 200

    * print "Prueba: Intentando crear 'Iron Man' de nuevo..."
    Given path apiUser, 'api', 'characters'
    And request { "name": "Iron Man", "alterego": "Otro Stark", "description": "Intento de duplicado", "powers": [Invisibility] }
    When method post
    Then status 400
    * match respo6333nse.error == "Character name already exists"

  @id:5 @read @casoNegativo
  Scenario: T-MARVEL-001-CA5 -Intentar obtener un personaje por ID que no existe
    * print "--- Test Negativo: GET con ID inexistente ---"
    Given path apiUser, 'api', 'characters', 999999
    When method get
    Then status 404
    * match response.error == "Character not found"

  @id:6 @update @casoNegativo
  Scenario: T-MARVEL-001-CA6 - Intentar actualizar un personaje que no existe
    * print "--- Test Negativo: PUT con ID inexistente ---"

    Given path apiUser, 'api', 'characters', 999999
    And request { "name": "Nobody", "alterego": "N/A", "description": "N/A", "powers": ["Invisibility"] }
    When method put

    Then status 404

    * match response.error == "Character not found"

  @id:7 @delete @casoNegativo
  Scenario: T-MARVEL-001-CA7 -Intentar eliminar un personaje que no existe
    * print "--- Test Negativo: DELETE con ID inexistente ---"
    Given path apiUser, 'api', 'characters', 999999
    When method delete
    Then status 404
    * match response.error == "Character not found"

  Scenario: Verificar que un endpoint público responde 200
    Given url 'https://httpbin.org/get'
    When method get
    Then status 200
