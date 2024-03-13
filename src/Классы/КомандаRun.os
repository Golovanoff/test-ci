#Использовать gitrunner
#Использовать fs

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Аргумент("PATH", "test.json", "Путь к json-файлу с настройками")
			.Обязательный(Ложь);

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	Сообщить("Подготовка...");

	ФайлПараметров = Новый Файл(Команда.ЗначениеАргумента("PATH"));
	Если Не ФайлПараметров.Существует() Тогда
		ВызватьИсключение "Не найден файл с параметрами " + ФайлПараметров.ПолноеИмя;
	КонецЕсли;

	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.ОткрытьФайл(ФайлПараметров.ПолноеИмя);
	Настройки = ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();
	
	НашРепо = Новый ГитРепозиторий();
	НашРепо.УстановитьРабочийКаталог(ТекущийКаталог());

	ВыполнитьПоНастройкам(НашРепо, Настройки);

КонецПроцедуры

Функция ВыполнитьПоНастройкам(Знач НашРепо, Знач Настройки) Экспорт

	Перем Пушить;

	ПутьКДонору = Настройки.Донор.Путь;
	КаталогДонора = Новый Файл(ПутьКДонору);
	Если Не КаталогДонора.Существует() Или Не КаталогДонора.ЭтоКаталог() Тогда
		ВызватьИсключение "Не найден путь (или это не каталог) к репо-донору " + ПутьКДонору;
	КонецЕсли;

	Донор = Новый ГитРепозиторий();
	Донор.УстановитьРабочийКаталог(ПутьКДонору);

	ФайлыДляПереноса = Настройки.Файлы;
	Пушить = Не Настройки.Свойство("Пушить", Пушить) Или Пушить = Истина;

	Для Каждого Коммит Из Настройки.Коммиты Цикл
		ОбработатьКоммит(НашРепо, Донор, Коммит, ФайлыДляПереноса, Пушить);
	КонецЦикла;

	Сообщить("Команда успешно выполнена.");

	Возврат Истина;
КонецФункции

Функция ОбработатьКоммит(Знач НашРепо, Знач Донор, Знач Коммит, Знач ФайлыДляПереноса, Знач Пушить)

	Сообщить("Обработка коммита " + Коммит);

	Донор.ПерейтиВВетку(Коммит, , Истина);
	
	Донор.ВыполнитьКоманду(КомандаСообщенияКоммита());
	СообщениеКоммита = СокрЛП(Донор.ПолучитьВыводКоманды());

	КаталогДонора = Донор.ПолучитьРабочийКаталог();
	КаталогПриемника = НашРепо.ПолучитьРабочийКаталог();
	
	Сообщить("Перенос файлов...");

	Для Каждого ФайлДляПереноса Из ФайлыДляПереноса Цикл
		
		Источник = Новый Файл(ОбъединитьПути(КаталогДонора, ФайлДляПереноса));
		Приемник = Новый Файл(ОбъединитьПути(КаталогПриемника, ФайлДляПереноса));

		ФС.ОбеспечитьКаталог(Приемник.Путь);
		Если Источник.ЭтоКаталог() Тогда
			ФС.КопироватьСодержимоеКаталога(Источник.ПолноеИмя, Приемник.ПолноеИмя);
		Иначе
			КопироватьФайл(Источник.ПолноеИмя, Приемник.ПолноеИмя);
		КонецЕсли;
	КонецЦикла;

	Сообщить("Фиксация...");

	НашРепо.ДобавитьФайлВИндекс(".");
	НашРепо.Закоммитить(СообщениеКоммита);
	
	Если Пушить Тогда
		Сообщить("Отправка...");
		НашРепо.Отправить();
	КонецЕсли;

	Возврат Истина;
КонецФункции

Функция КомандаСообщенияКоммита()
	Команда = Новый Массив;
	Команда.Добавить("log -1 --pretty=%B");
	Возврат Команда;
КонецФункции
