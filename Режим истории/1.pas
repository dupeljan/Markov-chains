uses crt;
const ms = 0;//Время задержки
	  test = false;//режим теста
type
	TEL = string[50];
	STRFile = file of TEL;
	list = ^element;

	Pneigbours = ^neigboursElem;

	neigboursElem = record
		TheNeighbor:list;
		next:Pneigbours;
	end;

	element = record
		word:TEL;
		next:list;
		//Для Соседей
		neigbours:integer; //Кол-во соседей
		firstNeighbor:Pneigbours;// Ссылка на первого соседа
		
	end;

function foundWord( first: list  ; x:TEL ):boolean;
var flag:boolean;
begin
	flag:=false;
	while ( first <> nil ) and ( not flag) do begin
		flag:= first^.word = x ;
		first:=first^.next;
	end;
	foundWord:= flag ;
end;



procedure CreateList(var first: list; var f: STRFile);
var buff:TEL;
	a,b:list;
	flag:boolean;
begin
	reset(f);
	if (EOF(f) ) Then
		writeln('file is empty')
	else begin

		read(f,buff);
		new(first);
		first^.word:=buff;
		first^.neigbours:=0;
		first^.firstNeighbor:=nil;
		
		a:=first;
		while( not(EOF(f) ) ) do begin
			read(f,buff);
			flag:=foundWord(first,buff);
			if (not flag ) then begin              
				new(b);
				b^.word:=buff;
				b^.neigbours:=0;
				b^.firstNeighbor:=nil;
				a^.next:=b;
				a:=b;
			end;
		end;
		a^.next:=nil;
	end;
end;

function wordInList(l:list; find: TEL):list;
var a: list;
begin
	a:=l;
	while ( a^.next <> nil ) and ( a^.word <> find ) do
		a:=a^.next;
	if ( a^.word = find) then
		wordInList:=a
	else begin
		writeln('ERROR: not found ',find);
		wordInList:=nil;
	end;
end;

procedure foundNeighbors(l: list; var f: STRFile; var arg:element);
var buff:TEL;
	a,b: Pneigbours;
	frst:boolean;
	i:longint;
begin
	
	reset(f);
	frst:=true;
	while (not (EOF (f) ) ) do begin
		read(f,buff);
		if ( buff = arg.word ) and ( not (EOF (f) ) ) then begin
			read(f,buff);

			//для случаев послед одинакрвых слов
			i:=filepos(f);
			seek(f,i-1);
			//
			if frst then begin
				new(arg.firstNeighbor);
				arg.firstNeighbor^.TheNeighbor:=wordInList(l,buff);
				a:=arg.firstNeighbor;
				frst:=false;
			end
			else begin
				new(b);
				b^.TheNeighbor:=wordInList(l,buff);
				a^.next:=b;
				a:=b;
			end;

			inc( arg.neigbours);
		end;
	end;//end While
	a^.next:=nil;	
end;

procedure writeNextWord({var f:text;}first:list; var arg: list);
var transit,i:integer;
	Point:Pneigbours;
	buff: pointer;
begin
		Point:=arg^.firstNeighbor;
		randomize;

		transit:=random(arg^.neigbours) + 1;
		for i:=2 to transit do
			Point:=Point^.next;

		if ( point <> nil ) then begin
			arg:=Point^.TheNeighbor;
			delay(ms);
			write(' ',arg^.word);
		end
		else
			arg:=first;
		
end;

procedure fileTransformation(var input: text; var output: STRFile);
var buffTel:TEL;
	buffStr:string;
begin
	reset(input);
	reset(output);

	while ( Not (EOF(input))) do begin
		{if ( EOLn(input)) then
			readln(input,buffStr)
		else}
			readln(input,buffStr);

		buffTel:=buffStr;
		write(output,buffTel);
	end;
	reset(output);
	while ( not EOF(output)) do begin	
		read(output, buffTel);
		//writeln('1 ',buffTel);
	end;

end;

var first,a:list;
	input: text;
	FileStr:STRFile;
	i:integer;
	key: char;
begin
	{$I-}
		assign(input,'input.txt');
		reset(input);
	{$I+}

	if ( IoResult = 0 ) then begin
		assign(FileStr,'Buff.hey');
		rewrite(FileStr);
		fileTransformation(input,FileStr);
		CreateList(first,FileStr);
	
		
		a:=first;
		repeat
			
			foundNeighbors(first,FileStr,a^);
			a:=a^.next
		until (a = nil);

		/// 
		
		if test then begin
			
			a:=first;
			i:=1;
			writeln('word in list');
			while ( a <> nil ) do begin
				writeln(i,')',a^.word);
				a:=a^.next;
				inc(i);
			end;

			a:=first;
			while ( a <> nil ) do begin
				i:=0;
				writeln('For word ',a^.word , ' neighbors = ', a^.neigbours);
				with a^ do begin
					while( firstNeighbor <> nil ) do begin
						inc(i);
						writeln('neigbour ', i,' ', firstNeighbor^.TheNeighbor^.word );
						firstNeighbor:=firstNeighbor^.next;
					end;
				end;
				a:=a^.next;
			end;
		end;
	    
		///
		a:=first;
		write(a^.word);
		key:='a';
		while (a <> nil) and (key <> #27) do begin 
			writeNextWord(first,a);
			key:=readkey;
		end;
		
		close(input);
		close(FileStr);

	end else
		writeln('Файл не найден');
end.
