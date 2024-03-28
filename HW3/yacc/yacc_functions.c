#include "yacc_functions.h"

id_table* table = NULL;

Function functions[10];
int numFunctions = 0;

Function* create_function_1(char* name, Valuef* expression) {
    Function* func = (Function*)malloc(sizeof(Function));
    if (func == NULL) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        exit(EXIT_FAILURE);
    }

    strcpy(func->name, name);
    func->numParams = 0;
    func->params = NULL;
    func->expression = expression;

    return func;
}

Function* create_function_2(char* name, char* param1, Valuef* expression) {
    Function* func = create_function_1(name, expression);

    Param* param = (Param*)malloc(sizeof(Param));
    if (param == NULL) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        exit(EXIT_FAILURE);
    }

    strcpy(param->name, param1);
    param->next = NULL;

    func->params = param;
    func->numParams = 1;

    return func;
}

Function* create_function_3(char* name, char* param1, char* param2, Valuef* expression) {
    Function* func = create_function_2(name, param1, expression);

    Param* param = (Param*)malloc(sizeof(Param));
    if (param == NULL) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        exit(EXIT_FAILURE);
    }

    strcpy(param->name, param2);
    param->next = func->params;
    func->params = param;
    func->numParams++;

    return func;
}


// Function to find the greatest common divisor (GCD) of two numbers
int gcd(int a, int b) {
    if (b == 0) {
        return a;
    }
    return gcd(b, a % b);
}

// Function to reduce a fraction to its simplest form
void reduce_fraction(Valuef* f) {
    int common_factor = gcd(f->numerator, f->denominator);

    // Divide both numerator and denominator by their greatest common divisor
    f->numerator /= common_factor;
    f->denominator /= common_factor;
}



Valuef* create_valuef(int numerator, int denominator) {
    Valuef* f = (Valuef *)malloc(sizeof(Valuef));
    f->numerator = numerator;
    f->denominator = denominator;
    reduce_fraction(f);
    return f;
}

Valuef* add_valuef(Valuef* f1, Valuef* f2) {
    int numerator = f1->numerator * f2->denominator + f2->numerator * f1->denominator;
    int denominator = f1->denominator * f2->denominator;
    return create_valuef(numerator, denominator);
}

Valuef* sub_valuef(Valuef* f1, Valuef* f2) {
    int numerator = f1->numerator * f2->denominator - f2->numerator * f1->denominator;
    int denominator = f1->denominator * f2->denominator;
    return create_valuef(numerator, denominator);
}

Valuef* mul_valuef(Valuef* f1, Valuef* f2) {
    int numerator = f1->numerator * f2->numerator;
    int denominator = f1->denominator * f2->denominator;
    return create_valuef(numerator, denominator);
}

Valuef* div_valuef(Valuef* f1, Valuef* f2) {
    int numerator = f1->numerator * f2->denominator;
    int denominator = f1->denominator * f2->numerator;

    // Check for division by zero
    if (f2->numerator == 0) {
        fprintf(stderr, "Error: Division by zero\n");
        return NULL;
    }

    return create_valuef(numerator, denominator);
}

void print_valuef(Valuef* f1) {

    printf("%db%d\n", f1->numerator, f1->denominator);
}

void print_table(id_table* temp){
	if( temp == NULL )
		return;
	print_table(temp->next);
}

void set_element( char* name, Valuef *value ){

	if( table == NULL ){
		table = (id_table*)malloc(sizeof(id_table));
		strcpy(table->identifier, name);
		table->value = value;
		table->next = NULL;
	}
	else{
		id_table* temp = table;
		while( temp->next != NULL && (strcmp(temp->identifier, name) != 0) ) temp = temp->next;
		if( strcmp( temp->identifier, name )==0 ){
			temp->value = value;
		}else{
			id_table* new_id_table = (id_table*)malloc(sizeof(id_table));
			new_id_table->value = value;
			strcpy(new_id_table->identifier, name);
			new_id_table->next = NULL;
			temp -> next = new_id_table;
		}
	}

    printf("Set %s to ", name);
}

Valuef *get_identifier(char* name){
	id_table* temp = table;
	while( temp != NULL ){
		if( strcmp(name, temp->identifier) == 0 )
			return temp->value;
		temp = temp -> next;
	}
	printf("%s does not exist\n", name);
	return 0;
}