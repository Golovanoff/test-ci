#Использовать cli

Процедура ВыполнитьПриложение()

    Приложение = Новый КонсольноеПриложение("test-ci", "Тестирование работы ci по сценариям", ЭтотОбъект);
    Приложение.Версия("v version","1.0.0");

    Приложение.ДобавитьКоманду("i init", "Инициализация репо-донора", Новый КомандаInit);
    Приложение.ДобавитьКоманду("r run", "Запуск тестов по настройке из json", Новый КомандаRun);

    Приложение.Запустить(АргументыКоманднойСтроки);

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач КомандаПриложения) Экспорт
    КомандаПриложения.ВывестиСправку();
КонецПроцедуры

ВыполнитьПриложение();